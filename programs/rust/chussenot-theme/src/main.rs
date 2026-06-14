use std::env;
use std::fs;
use std::path::Path;
use std::process::Command;

struct GitInfo {
    branch: String,
    dirty: bool,
}

struct ThemeMetadata {
    git: Option<GitInfo>,
    python: Option<String>,
    node: Option<String>,
    go: Option<String>,
    rust: Option<String>,
    load: Option<String>,
    load_level: Option<&'static str>,
    docker: bool,
}

impl ThemeMetadata {
    fn collect() -> Self {
        let current_dir = env::current_dir().ok();
        let load = load_average();
        let load_level = load
            .as_deref()
            .and_then(|value| value.parse::<f32>().ok())
            .map(load_level);

        Self {
            git: current_dir.as_deref().and_then(git_info),
            python: command_version("python3", &["--version"]).map(trim_patch_version),
            node: command_version("node", &["--version"]).map(|value| {
                trim_patch_version(value.trim_start_matches('v').to_string())
            }),
            go: command_version("go", &["version"]).and_then(parse_go_version),
            rust: rust_version(),
            load,
            load_level,
            docker: in_docker(),
        }
    }

    fn print(&self) {
        if let Some(git) = &self.git {
            println!("git_branch={}", git.branch);
            println!("git_dirty={}", if git.dirty { "true" } else { "false" });
        }

        print_optional("python", self.python.as_deref());
        print_optional("node", self.node.as_deref());
        print_optional("go", self.go.as_deref());
        print_optional("rust", self.rust.as_deref());
        print_optional("load", self.load.as_deref());
        print_optional("load_level", self.load_level);

        println!("docker={}", if self.docker { "true" } else { "false" });
    }
}

fn main() {
    ThemeMetadata::collect().print();
}

fn print_optional(key: &str, value: Option<&str>) {
    if let Some(value) = value {
        println!("{key}={value}");
    }
}

fn command_version(command: &str, args: &[&str]) -> Option<String> {
    let output = Command::new(command).args(args).output().ok()?;
    let text = if output.status.success() {
        if output.stdout.is_empty() {
            String::from_utf8(output.stderr).ok()?
        } else {
            String::from_utf8(output.stdout).ok()?
        }
    } else {
        return None;
    };

    let trimmed = text.trim();
    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

fn trim_patch_version(version: String) -> String {
    match version.rsplit_once('.') {
        Some((prefix, _)) => prefix.to_string(),
        None => version,
    }
}

fn parse_go_version(version: String) -> Option<String> {
    let trimmed = version.trim();
    let token = trimmed.split_whitespace().nth(2)?;
    Some(trim_patch_version(
        token.trim_start_matches("go").to_string(),
    ))
}

fn rust_version() -> Option<String> {
    command_version("rustc", &["--version"])
        .or_else(|| command_version("rust", &["--version"]))
        .and_then(parse_rust_version)
}

fn parse_rust_version(version: String) -> Option<String> {
    let trimmed = version.trim();
    let token = trimmed.split_whitespace().nth(1)?;
    Some(trim_patch_version(token.to_string()))
}

fn git_info(current_dir: &Path) -> Option<GitInfo> {
    if !git_success(current_dir, &["rev-parse", "--git-dir"]) {
        return None;
    }

    let branch = git_output(current_dir, &["symbolic-ref", "--quiet", "--short", "HEAD"])
        .or_else(|| git_output(current_dir, &["rev-parse", "--short", "HEAD"]))?;

    let dirty = !git_success(current_dir, &["diff", "--quiet", "--ignore-submodules", "--cached"])
        || !git_success(current_dir, &["diff-files", "--quiet", "--ignore-submodules"]);

    Some(GitInfo { branch, dirty })
}

fn git_output(current_dir: &Path, args: &[&str]) -> Option<String> {
    let output = Command::new("git")
        .args(args)
        .current_dir(current_dir)
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }

    let text = String::from_utf8(output.stdout).ok()?;
    let trimmed = text.trim();
    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

fn git_success(current_dir: &Path, args: &[&str]) -> bool {
    Command::new("git")
        .args(args)
        .current_dir(current_dir)
        .status()
        .map(|status| status.success())
        .unwrap_or(false)
}

fn load_average() -> Option<String> {
    if let Some(load) = linux_load_average() {
        return Some(load);
    }

    macos_load_average()
}

fn linux_load_average() -> Option<String> {
    let contents = fs::read_to_string("/proc/loadavg").ok()?;
    let load = contents.split_whitespace().next()?;
    Some(load.to_string())
}

fn macos_load_average() -> Option<String> {
    let output = Command::new("sysctl")
        .args(["-n", "vm.loadavg"])
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }

    let text = String::from_utf8(output.stdout).ok()?;
    let normalized = text.replace(['{', '}'], "");
    let load = normalized.split_whitespace().next()?;
    Some(load.to_string())
}

fn load_level(load: f32) -> &'static str {
    if load < 1.0 {
        "green"
    } else if load < 2.0 {
        "yellow"
    } else {
        "red"
    }
}

fn in_docker() -> bool {
    Path::new("/.dockerenv").exists()
        || env::var("DOCKER_CONTAINER")
            .map(|value| !value.is_empty())
            .unwrap_or(false)
}
