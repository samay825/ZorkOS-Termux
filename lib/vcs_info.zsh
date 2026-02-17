
autoload -Uz +X regexp-replace VCS_INFO_formats 2>/dev/null || return 0

typeset PATCH='for tmp (base base-name branch misc revision subdir) hook_com[$tmp]="${hook_com[$tmp]//\%/%%}"'
typeset PATCH_ID=vcs_info-patch-9b9840f2-91e5-4471-af84-9e9a0dc68c1b
if [[ "$functions[VCS_INFO_formats]" != *$PATCH_ID* ]]; then
  regexp-replace 'functions[VCS_INFO_formats]' \
    "VCS_INFO_hook 'post-backend'" \
    ': ${PATCH_ID}; ${PATCH}; ${MATCH}'
fi
unset PATCH PATCH_ID
