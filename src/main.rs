use anyhow::Result;
use clap::{Parser, Subcommand};
use std::path::PathBuf;

#[derive(Parser)]
#[command(version, about = "Temporary editable environments for Nix derivations")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Open an editable environment for a Nix derivation
    Open {
        /// Path to the .drv file or Nix store path
        derivation: String,
        /// Output patch file (default: <derivation-name>.patch)
        #[arg(short, long)]
        output: Option<PathBuf>,
    },
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    match cli.command {
        Commands::Open { derivation, output } => open(derivation, output),
    }
}

fn open(derivation: String, output: Option<PathBuf>) -> Result<()> {
    let source = unpack_source(&derivation)?;
    let patch = run_session(&source)?;
    write_patch(&patch, output.as_deref())?;
    Ok(())
}

fn unpack_source(_derivation: &str) -> Result<PathBuf> {
    // TODO: nix show-derivation → locate src → copy to tempdir → git init
    todo!("unpack derivation source")
}

fn run_session(_source: &PathBuf) -> Result<String> {
    // TODO: spawn $SHELL in source dir, wait for exit, run git diff
    todo!("run interactive session")
}

fn write_patch(_patch: &str, _output: Option<&std::path::Path>) -> Result<()> {
    // TODO: write to output path or stdout
    todo!("write patch output")
}
