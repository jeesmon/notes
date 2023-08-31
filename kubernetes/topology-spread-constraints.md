# TopologySpreadConstraints

## Notes

* Cannot expect 100% even distribution of pods across nodes as MaxSkew should be at least 1.
* `whenUnsatisfiable` is set to `ScheduleAnyway` to allow pods to be scheduled even if the constraints are not met. This may not trigger cluster autoscaler to scale up the cluster if there are not enough nodes to satisfy the constraints.
* `whenUnsatisfiable` is set to `DoNotSchedule` to prevent pods from being scheduled if the constraints are not met. This may cause pods to be stuck in `Pending` state if there are not enough nodes to satisfy the constraints after cluster autoscaler tries to scales up the cluster.

## Links
* https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
* https://mby.io/blog/topology-spread-constraints/
