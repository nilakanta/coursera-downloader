// Generated by CoffeeScript 1.9.2
var Store;

Store = (function() {
  function Store() {}

  Store.prototype.incomingTasks = function() {
    var json;
    json = window.localStorage.tasks;
    if (json) {
      return window.JSON.parse(json);
    }
  };

  Store.prototype.addIncomingTasks = function(value) {
    var json;
    this.clearIncoming();
    json = window.JSON.stringify(value);
    return window.localStorage.tasks = json;
  };

  Store.prototype.clearIncoming = function() {
    return window.localStorage.removeItem('tasks');
  };

  return Store;

})();

angular.module('Store', []).factory('store', function($window) {
  return new Store;
});
