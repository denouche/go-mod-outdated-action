# Go mod outdated action


## Example of usage


```yaml
name: Check outdated Go dependencies in PR

on:
  workflow_dispatch:
  pull_request:
    types: ['opened', 'edited', 'reopened', 'synchronize']

jobs:

  build:

    runs-on: ubuntu-latest

    steps:

      - name: Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 0

      - name: Set up Go
        uses: actions/setup-go@v2
        with:
          go-version: 1.16

      - name: Go mod outdated
        id: outdated
        uses: denouche/go-mod-outdated-action@main
        with:
          ignore: |
            golang.org/x/oauth2
            github.com/stretchr/testify
        env:
          GOPRIVATE: github.com/your-company/*

      - name: Find existing Comment
        uses: peter-evans/find-comment@51dad149104d98524da58837393d47942ae0f86f
        id: find_comment
        with:
          issue-number: ${{ github.event.pull_request.number }}
          comment-author: 'github-actions[bot]'
          body-includes: Go mod dependencies checker
        continue-on-error: true

      - name: Add comment
        uses: peter-evans/create-or-update-comment@a35cf36e5301d70b76f316e867e7788a55a31dae
        if: steps.outdated.outputs.is-up-to-date == 'false'
        with:
          comment-id: ${{ steps.find_comment.outputs.comment-id }}
          edit-mode: replace
          issue-number: ${{ github.event.pull_request.number }}
          body: |
            Go mod dependencies checker
            Some dependencies are outdated:
            ```
            ${{ steps.outdated.outputs.outdated }}
            ```

      - name: Add comment
        uses: peter-evans/create-or-update-comment@a35cf36e5301d70b76f316e867e7788a55a31dae
        if: steps.outdated.outputs.is-up-to-date == 'true'
        with:
          comment-id: ${{ steps.find_comment.outputs.comment-id }}
          edit-mode: replace
          issue-number: ${{ github.event.pull_request.number }}
          body: |
            Go mod dependencies checker
            All your direct dependencies are up to date! Well done!

```