require 'fog/core/model'

module Fog
  module Compute
    class Google
      module ModelHelpers

        def included(base)
          base.extend(ClassMethods)
        end

        def is_url?(string)
          string.start_with?('http://')
        end

        module ClassMethods
          def attribute_with_url_and_name(name, options = {})
            attribute(name, options)
            
            setter_method = "_set_#{name}"
            getter_method = "_get_#{name}"

            class_eval <<-EOS, __FILE__, __LINE__

              alias_method :#{setter_method}, :#{name}=
              alias_method :#{getter_method}, :#{name}
              
              def #{name}
                Fog::Logger.warning("Attribite #{name} of \#{self.class.name} can contain url or name." + 
                  "Use #{name}_url or #{name}_name to determine what you need.")
                self.#{getter_method}
              end

              def #{name}=(new_#{name})
                self.#{setter_method}(new_#{name})
              end

              def #{name}_url
                @#{name}_url ||= is_url?(self.#{setter_method}) ? self.#{setter_method} : self.#{setter_method}
              end

              def #{name}_name
                @#{name}_name ||= #{name}_is_url? ? 
              end

              def #{name}_is_url?
                self.#{getter_method}.start_with?('http://')
              end

            EOS

          end
        end
      end
    end
  end
end

