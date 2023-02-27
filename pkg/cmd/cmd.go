package cmd

import (

	"github.com/spf13/cobra"
)

func NewRootCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:     "demo-ctl",
		Short:   "demo cli",
		Version: Version,
	}
        cmd.AddCommand(VersionCmd())
        return cmd
}
