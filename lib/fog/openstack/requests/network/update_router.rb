module Fog
  module Network
    class OpenStack

      class Real

        # Update Router
        #
        # Beyond the name and the administrative state, the only 
        # parameter which can be updated with this operation is 
        # the external gateway.
        #
        #     router = Fog::Network[:openstack].routers.first
        #     net = Fog::Network[:openstack].networks.first
        #
        #     # :external_gateway_info can be either a
        #     # Fog::Network::OpenStack::Network or a Hash
        #     # like { 'network_id' => network.id }
        #     Fog::Network[:openstack].update_router router.id,
        #                                            :name => 'foo',
        #                                            :external_gateway_info => net,
        #                                            :admin_state_up => true
        #
        # @see http://docs.openstack.org/api/openstack-network/2.0/content/router_update.html
        def update_router(router_id, options = {})
          data = { 'router' => {} }
          
          vanilla_options = [:name, :admin_state_up]

          egi = options[:external_gateway_info]
          if egi
            if egi.is_a?(Fog::Network::OpenStack::Network)
              data['router']['external_gateway_info'] = { 'network_id' => egi.id }
            elsif egi.is_a?(Hash) and egi['network_id']
              data['router']['external_gateway_info'] = egi
            else
              raise ArgumentError.new('Invalid external_gateway_info attribute')
            end
          end

          vanilla_options.reject{ |o| options[o].nil? }.each do |key|
            data['router'][key] = options[key]
          end

          request(
            :body     => Fog::JSON.encode(data),
            :expects  => 200,
            :method   => 'PUT',
            :path     => "routers/#{router_id}.json"
          )
        end
      end

      class Mock
        def update_router(router_id, options = {})
          router = self.data['routers'].find { |r| r['id'] == router_id }
          raise Fog::Network::OpenStack::NotFound unless router
          data = { 'router' => router }

          vanilla_options = [:name, :admin_state_up]

          egi = options[:external_gateway_info]
          if egi
            if egi.is_a?(Fog::Network::OpenStack::Network)
              data['router']['external_gateway_info'] = { 'network_id' => egi.id }
            elsif egi.is_a?(Hash) and egi['network_id']
              data['router']['external_gateway_info'] = egi
            else
              raise ArgumentError.new('Invalid external_gateway_info attribute')
            end
          end

          vanilla_options.reject{ |o| options[o].nil? }.each do |key|
            data['router'][key] = options[key]
          end
          response = Excon::Response.new
          response.status = 201
          response.body = data
          response
        end
      end

    end
  end
end
