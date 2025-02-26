# Add Homebrew to PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$PATH:$HOME/.rover/bin:/opt/homebrew/opt/postgresql@15/bin:$HOME/code/go/bin:/opt/local/bin:/opt/local/sbin:/usr/local/go/bin"

# java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home

# pnpm
export PNPM_HOME="/Users/adamcooper/.config/local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

