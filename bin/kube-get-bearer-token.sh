#!/bin/bash

THIS_DIR=$( (cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) )

run-kubectl() {
    "$THIS_DIR/kubectl.sh" "$@"
}

# Run kubernetes with configured context
run-kubectl-ctx() {
    local opts=()
    if [[ -n "$KUBE_CONTEXT" ]]; then
        opts+=(--context "$KUBE_CONTEXT")
    fi
    run-kubectl "${opts[@]}" "$@"
}

KUBE_USER=admin-user
SECRETS=$(run-kubectl-ctx -n kube-system get secret -o template -o go-template='{{ range.items }}{{ .metadata.name }}{{"\n"}}{{end}}')

if SECRET=$(grep "$KUBE_USER" <<<"$SECRETS"); then
    run-kubectl-ctx -n kube-system describe secret "$SECRET"
else
    exit 1
fi
