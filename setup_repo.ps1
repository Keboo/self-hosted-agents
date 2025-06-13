# Disable merge commits
gh repo edit --enable-merge-commit=false
#Enable auto merge
gh repo edit --enable-auto-merge
# Delete head branch after merge
gh repo edit --delete-branch-on-merge
#Disable wiki
 gh repo edit --enable-wiki=false