# REST-API of VirtDancer

VirtDancer is built from two parts: the backend exposing a REST-API and the frontend written in HTML/JS/CSS.

_Disclaimer_: this may not be a true REST-API for java-coders as it always want's json but it works. Please
don't annoy me to make this REST-API  level 9100 or something.

## Resources

### GET /vm

Returns a list of the following objects:
```js
{
  "uuid": "f42874e0-cbcc-de8a-493d-d30069833905",  // UUID of the VM
  "name": "LittleFox-Tsa",                         // name of the VM
  "active": true,                                  // is the VM running?
}
```

### GET /vm/&lt;uuid&gt;

Returns an object in the following form:
```js
{
  "id":         42,                                     // id unique to the current host of the VM
  "uuid":       "f42874e0-cbcc-de8a-493d-d30069833905", // globally unique ID of the VM
  "name":       "LittleFox-Tsa",                        // name of the VM 
  "active":     true,                                   // is the VM currently running
  "persistent": true,                                   // is the configuration saved on the host?
  "updated":    false,                                  // was the configuration updated since starting the VM?
  "os":         "hvm",                                  // virtualization-type
  "autostart":  true,                                   // start automatically when the host is started
  "info":       {
    "maxMem":    4194304,                               // maximum memory for VM in KBytes
    "memory":    4194304,                               // current memory for VM in KBytes
    "cpuTime":   101960000000,                          // CPU-time of the VM
    "nrVirtCpu": 3,                                     // number of CPUs for the VM
    "state":     1,                                     // state of the VM, see below
  },
}
```

#### State-constants

TBD; in the meantime look here: https://metacpan.org/pod/Sys::Virt::Domain#DOMAIN-STATE

### POST /vm/&lt;uuid&gt;/action

Accepts a JSON-Object in the following format:
```js
{
  "action": "stop",
}
```

Action can be:
* start -> just start or resume the VM
* pause -> suspend the VM
* shutdown -> graceful shutdown of the VM (ACPI-shutdown signal)
* destroy -> kill the VM (useful for windows-guests as these often ignore ACPI-shutdown -.-)
