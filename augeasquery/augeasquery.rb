module MCollective
  module Agent
    class Augeasquery<RPC::Agent

      action 'query' do

        begin
          require 'augeas'
        rescue Exception => e
          reply.fail! e.to_s
        end

        aug = Augeas.open

        if request[:transform]
          request[:transform].split(/,/).each do |transform|
            lens, path =  transform.split(/=/)
            if aug.match('/augeas/load/'+lens).length > 0
              aug.set('/augeas/load/'+lens+'/incl[last()+1]', path)
            else
              aug.set('/augeas/load/'+lens+'/lens', lens+'.lns')
              aug.set('/augeas/load/'+lens+'/incl', path)
            end
          end
          aug.load()
        end

        matched = []

        matches = aug.match( request[:query] )

        matches.each do | match |
          if aug.get( match )
            matched << match+" = "+aug.get( match )
          else
            matched << match
          end
        end

        reply[:matched] = matched || []
      end
    end
  end
end
