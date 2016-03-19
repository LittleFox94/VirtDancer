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
})();
