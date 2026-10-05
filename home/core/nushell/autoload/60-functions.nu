# Shell functions.
# `yy` (yazi cd-on-exit) comes from the Home Manager yazi integration.

def reload [] {
    exec nu
}

# Add a Git worktree and share the main checkout's Zed settings with it.
def wtz [path: path, ...rest] {
    ^git worktree add $path ...$rest
    let main = (^git rev-parse --show-toplevel | str trim)
    let zed = ($main | path join ".zed")
    if ($zed | path exists) {
        ^ln -s $zed ($path | path join ".zed")
    }
}
