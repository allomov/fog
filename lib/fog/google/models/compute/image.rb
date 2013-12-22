require 'fog/core/model'

module Fog
  module Compute
    class Google

      class Image < Fog::Model

        # why not id ?
        identity :name

        attribute :id
        attribute :kind
        attribute :self_link, :aliases => 'selfLink'
        attribute :creation_timestamp, :aliases => 'creationTimestamp'
        attribute :deprecated
        attribute :description
        

        # This attribute is not available in the representation of an
        # 'image' returned by the GCE servser (see GCE API). However,
        # images are a global resource and a user can query for images
        # across projects. Therefore we try to remember which project
        # the image belongs to by tracking it in this attribute.
        attribute :project

        # A RawDisk, e.g. -
        # {
        #   :source         => url_to_gcs_file,
        #   :container_type => 'TAR',
        #   :sha1Checksum   => ,
        # }
        attribute :raw_disk

        attribute :status

        def reload
          requires :name

          data = service.get_image(name, self.project).body

          self.merge_attributes(data)
          self
        end

        def save
          requires :name
          requires :raw_disk

          options = { 'description'     => description }

          response = service.insert_image(name, raw_disk, options)
          
          operation = service.operations.new(response.body)
          operation.wait

          puts "Fog::Image#save -> operation: " + operation.inspect

          data = service.backoff_if_unfound {
            service.get_image(self.name).body
          }

          # Track the name of the project in which we insert the image
          # data.merge!('project' => service.project)
          data = {}
          
          self.project = self.service.project

          service.images.merge_attributes(data)
        end

        def resource_url
          # "compute/v1/projects/#{project}/global/images/#{image}"
          "#{self.project}/global/images/#{name}"
        end

        def delete
          requires :name

          response = service.delete_image(name)

          operation = service.operations.new(response.body)
          operation.wait          
        end

      end
    end
  end
end
