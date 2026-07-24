---
page: 299
title: HTTP Status Code You Should Know
title_de: HTTP Status Code You Should Know
tags: [api, networking, devops]
source: linkedin-posts-2024-blue.pdf
ingest: text-extract-v1
---

## Summary (EN)
- 🔹 Control Plane Components 1. API Server The API server talks to all the components in the k8s cluster. All the operations on pods are
- 4. etcd etcd is a key-value store used as Kubernetes' backing store for all cluster data. 🔹 Nodes 1. Pods A pod is a group of containers and is the smallest unit that k8s administers. Pods have a single IP
- 2. Kubelet An agent that runs on each node in the cluster. It ensures containers are running in a Pod. 3. Kube Proxy kube-proxy is a network proxy that runs on each node in your cluster. It routes traffic coming into a

## Zusammenfassung (DE)
- (Text-Extrakt — Diagramm siehe PDF Seite 299. Vision-Ingest kann DE-Summary ergänzen.)

## Diagram (what it shows)
- Refer to `assets/linkedin-posts-2024-blue.pdf` page 299 for the infographic.
- Re-run `scripts/ingest-pages.py --vision` to enrich diagram description.

## When to use / Wann nutzen
- **Use / Nutzen:** When this pattern matches your architecture question (see tags: api, networking, devops).
- **Avoid / Vermeiden:** When simpler patterns suffice — validate with `@foundations` and `@ponytail`.

## Trade-offs
| EN | DE |
|----|-----|
| See summary bullets | Siehe Summary — bei Unsicherheit PDF Seite 299 |
