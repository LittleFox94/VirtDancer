(function(){
    var app = angular.module("VirtDancer", []);
    app.controller('VirtDancerController', ['$http', function($http) {
        this.updateData = function() {
            var store = this;
            $http.get('/vm').success(function (data) {
                data.forEach(function(elem) {
                    $http.get('/vm/' + elem.uuid).success(function (vmdata) {
                        store.vms.push(vmdata);
                        if(vmdata.active) {
                            store.num_running++;
                        }
                    });
                });
            });
        };

        this.resetApp = function() {
            this.active_vm = null;
            this.vnc_uuid = null;
            this.num_running = 0;
            this.vms = [];
            this.updateData();
        };

        this.action = function(action) {
            if(this.active_vm === null) {
                return;
            }

            $http.post('/vm/' + this.active_vm.uuid + '/action', {"action": action }).error(function (error) {
                console.log(error);
            });
        };

        this.vnc = function() {
            if(this.active_vm !== null) {
                window.location.href = "vnc.html?uuid=" + this.active_vm.uuid;
            }
        };

        this.resetApp();
    }]);

    // stolen from https://gist.github.com/thomseddon/3511330, thanks!
    app.filter('bytes', function() {
        return function(bytes, precision) {
            if (isNaN(parseFloat(bytes)) || !isFinite(bytes) || bytes == 0) return '-';
            if (typeof precision === 'undefined') precision = 1;
            var units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB'],
                number = Math.floor(Math.log(bytes) / Math.log(1024));
            return (bytes / Math.pow(1024, Math.floor(number))).toFixed(precision) +  ' ' + units[number];
        }
    });

    app.filter('nsDuration', function() {
        return function(nanoseconds) {
            if(nanoseconds == 0) return '-';

            var units     = ['ns', 'µs', 'ms',  's', 'min', 'h', 'd'];
            var factors   = [1,    1000, 1000, 1000,    60,  60,  24];
            var tmps      = [0,       0,    0,     0,    0,   0,   0];
            var output    = nanoseconds;
            var unitIndex = 0;

            while((output / factors[unitIndex + 1]) >= 1 && unitIndex < units.length) {
                var oldValue    = output;
                output          = Math.floor(output / factors[unitIndex + 1]);
                tmps[unitIndex] = oldValue - (output * factors[unitIndex + 1]);
                unitIndex++;
            }

            var outputString = output + units[unitIndex];
            for(var i = unitIndex - 1; i >= 0; i--) {
                if(tmps[i] == 0) {
                    continue;
                }

                outputString += " " + tmps[i] + units[i];
            }

            return outputString;
        }
    });
})();
