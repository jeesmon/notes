# CRD Versioning

From: https://github.com/kube-object-storage/lib-bucket-provisioner/issues/132#issuecomment-524088238

The best versioning story IMO to avoid the challenges with CRD versioning is the following:

* Newer versions of the library should be backward compatible.
  * Deprecated properties would be ignored
  * Added properties would have defaults that work for the previous versions of the CRD and the latest library
* Properties added to the CRD would be ignored by older version of the library

If this is done, there isn't a need to change the CRD version every time a property changes.
