// Generated by CoffeeScript 1.9.2
var dependencies;

dependencies = ['Store', 'ClassesService'];

angular.module('badge', dependencies).run(function(store, classesService) {
  return window.badge = new BadgeController(store, classesService);
});
