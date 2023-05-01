# Kubernetes Routing

* https://kubernetes.io/docs/concepts/services-networking/topology-aware-routing/

Look for `hints` in `EndpointSlice` to confirm
```
endpoints:
  - addresses:
      - "10.1.2.3"
    conditions:
      ready: true
    hostname: pod-1
    zone: zone-a
    hints:
      forZones:
        - name: "zone-a"
```
