require 'rjb'

class ServiceClient

  def initialize()
     @path = File.dirname(__FILE__) +"/../lib/wmjsonclient.jar;"
     @path = @path + File.dirname(__FILE__) + "/../lib/client.jar;"
     @path = @path + File.dirname(__FILE__) + "/../lib/enttoolkit.jar"
     Rjb::load(@path)
     @j_hash_map = Rjb::import('java.util.HashMap')
     @j_svc_client = Rjb::import('com.gxs.wmclient.ServiceClient')
     @svc_intrfce = @j_svc_client.new
     @j_string = Rjb::import('java.lang.String')
  end

  def run_service(url, user, pass, service, inputs)
       #Need to turn the ruby hash inputs into a java HashMap
       j_input = @j_hash_map.new
       j_input = map_ruby_to_java_hash(inputs)
       output = @svc_intrfce.runService(url,user,pass,service,j_input)
       r_output = map_java_to_ruby_hash(output)
       r_output
  end

  def map_ruby_to_java_hash(hash)
    j_hash = @j_hash_map.new
    hash.each do |k,o|

       if(o.is_a? Hash)
         puts "#{k} => #{o.class}[#{o.size}]"
         j_hash.put(k.to_s,map_ruby_to_java_hash(o))
       else
         puts "#{k} => #{o}"
         j_hash.put(k.to_s,o)
       end
    end
    j_hash
  end

  def map_java_to_ruby_hash(j_hash)
    r_hash = Hash.new
    j_iter = Rjb::import("java.util.Iterator")
    j_set = Rjb::import("java.util.Set")
    it = j_hash.keySet().iterator();
    while it.hasNext()
      k = it.next().toString()
      o = j_hash.get(k)
      if o._classname == "java.util.HashMap"
        r_hash[k.to_sym] = map_java_to_ruby_hash(o)
      else
        r_hash[k.to_sym] = o.toString();
      end
    end
    r_hash
  end

end