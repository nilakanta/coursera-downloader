// Generated by CoffeeScript 1.9.2
var ClassesService;

ClassesService = (function() {
  function ClassesService(store1) {
    this.store = store1;
  }

  return ClassesService;

})();

angular.module('ClassesService', ['Store']).factory('classesService', function(store) {
  return new ClassesService(store);
});
