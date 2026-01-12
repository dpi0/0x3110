package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

func mounted(mp string) bool {
	out, err := exec.Command("lsblk", "-f", "-o", "MOUNTPOINTS").Output()
	if err != nil {
		return false
	}
	for l := range strings.SplitSeq(string(out), "\n") {
		if strings.TrimSpace(l) == mp {
			return true
		}
	}
	return false
}

func main() {
	mp := flag.String("mount-point", "", "")
	iv := flag.Int("interval", 60, "")
	grace := flag.Int("grace-minutes", 5, "")
	ex := flag.String("exec-on-error", "", "")
	lf := flag.String("log", "", "")

	flag.Usage = func() {
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "mount-point-alert — monitor a filesystem mount and trigger alerts")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "USAGE:")
		fmt.Fprintln(os.Stderr, "  mount-point-alert --mount-point PATH --exec-on-error CMD --log FILE [options]")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "REQUIRED OPTIONS:")
		fmt.Fprintln(os.Stderr, "  --mount-point PATH       Absolute mount point to monitor")
		fmt.Fprintln(os.Stderr, "  --exec-on-error CMD      Command executed after sustained unmount")
		fmt.Fprintln(os.Stderr, "  --log FILE               Log file path")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "OPTIONAL OPTIONS:")
		fmt.Fprintln(os.Stderr, "  --interval SECONDS       Check interval (default: 60)")
		fmt.Fprintln(os.Stderr, "  --grace-minutes MIN      Minutes unmounted before alerting (default: 5)")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "BEHAVIOR:")
		fmt.Fprintln(os.Stderr, "  • Checks mount presence every interval")
		fmt.Fprintln(os.Stderr, "  • Fires alert only after grace period")
		fmt.Fprintln(os.Stderr, "  • Repeats alert every grace period while unmounted")
		fmt.Fprintln(os.Stderr, "")
	}

	flag.Parse()

	if flag.NFlag() == 0 {
		flag.Usage()
		return
	}

	if *mp == "" || *ex == "" || *lf == "" || *iv <= 0 || *grace <= 0 {
		flag.Usage()
		return
	}

	if !filepath.IsAbs(*mp) {
		return
	}

	f, err := os.OpenFile(*lf, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
	if err != nil {
		return
	}
	defer func() { _ = f.Close() }()

	log := func(level, msg string) {
		ts := time.Now().Format("2006-01-02 15:04:05")
		_, _ = f.WriteString(ts + " [" + level + "] " + msg + "\n")
	}

	if !mounted(*mp) {
		log("ERROR", "startup: mount missing at "+*mp)
		_ = exec.Command("sh", "-c", *ex).Start()
	}

	var downSince time.Time
	var lastExec time.Time

	t := time.NewTicker(time.Duration(*iv) * time.Second)
	defer t.Stop()

	for range t.C {
		if mounted(*mp) {
			if !downSince.IsZero() {
				log("INFO", "mount restored at "+*mp)
			}
			downSince = time.Time{}
			continue
		}

		if downSince.IsZero() {
			downSince = time.Now()
			log("WARN", "mount lost at "+*mp)
			continue
		}

		if time.Since(downSince) < time.Duration(*grace)*time.Minute {
			continue
		}

		if lastExec.IsZero() || time.Since(lastExec) >= time.Duration(*grace)*time.Minute {
			log("ERROR", "mount still down, executing alert command")
			_ = exec.Command("sh", "-c", *ex).Start()
			lastExec = time.Now()
		}
	}
}
