require 'xcodeproj'

module Xcodeproj
  class Project

    def unit_test_dev_pods
      return groups.select { |e| e.name == "Development Pods" }.map { |e|
        e.children.map { |x| x.to_s  } 
      }.flatten.uniq
    end

    def unit_test_dependency_pods
      return groups.select { |e| e.name == "Pods" }.map { |e|
        e.children.map { |x| x.to_s  } 
      }.flatten.uniq
    end

    def unit_test_all_pods
      unit_test_dev_pods() + unit_test_dependency_pods()
    end

  end
end