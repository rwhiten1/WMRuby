require "test/unit"
require File.dirname(__FILE__) + "/../lib/service_client"
require "rjb"

class ServiceClientTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # set up the RJB JVM
     #@path = File.dirname(__FILE__) +"/../lib/wmjsonclient.jar;"
     #@path = @path + File.dirname(__FILE__) + "/../lib/client.jar;"
     #@path = @path + File.dirname(__FILE__) + "/../lib/enttoolkit.jar"
     #Rjb::load(@path)
     #@j_hash = Rjb::import("java.util.HashMap")
    @url = "ohedf036.internal.gxs.com:5555";
    @user = "Administrator"
    @pass = "manage"
    @svc_client = ServiceClient.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_map_ruby_hash_to_java_hash
      #make this one multilevel
    r_hash = Hash.new
    child1 = Hash.new
    child2 = Hash.new
    child1[:c1k1] = "c1value1"
    child1[:c1k2] = child2
    child2[:c2k1] = "c2value1"
    child2[:c2k2] = "c2value2"
    r_hash[:k1] = "value1"
    r_hash[:k2] = "value2"
    r_hash[:k3] = child1

    j_hash =   @svc_client.map_ruby_to_java_hash(r_hash)
    assert_not_nil j_hash
    j_child1 = j_hash.get("k3")
    assert_not_nil j_child1

    j_child2 = j_child1.get("c1k2")
    assert_not_nil j_child2

    assert_equal r_hash[:k1],j_hash.get("k1").toString()
    assert_equal r_hash[:k2],j_hash.get("k2").toString()
    assert_equal child1[:c1k1], j_child1.get("c1k1").toString()
    assert_equal child2[:c2k1], j_child2.get("c2k1").toString()
    assert_equal child2[:c2k2], j_child2.get("c2k2").toString() 

  end

  def test_map_java_hash_to_ruby_hash
    j_hash = Rjb::import("java.util.HashMap")
    j_top = j_hash.new
    j_child1 = j_hash.new
    j_child2 = j_hash.new

    j_top.put("k1","value1")
    j_top.put("k2","value2")
    j_top.put("k3",j_child1)
    j_child1.put("c1k1","c1value1")
    j_child1.put("c1k2",j_child2)
    j_child2.put("c2k1","c2k1value1")
    j_child2.put("c2k2","c2k1value2")
    j_child2.put("c2k3","c2k1value3")

    r_hash = @svc_client.map_java_to_ruby_hash(j_top)

    assert_not_nil r_hash
    r_c1 = r_hash[:k3]
    assert_not_nil r_c1

    r_c2 = r_c1[:c1k2]
    assert_not_nil r_c2

    assert_equal j_top.get("k1").toString(), r_hash[:k1]
    assert_equal j_top.get("k2").toString(), r_hash[:k2]
    assert_equal j_child1.get("c1k1").toString(),r_c1[:c1k1]
    assert_equal j_child2.get("c2k1").toString(),r_c2[:c2k1]
    assert_equal j_child2.get("c2k2").toString(),r_c2[:c2k2]
    assert_equal j_child2.get("c2k3").toString(),r_c2[:c2k3]
  end

  #I am trying to hide all of the Java code behind the ServiceClient.  I want
  #to keep Java as far away from the real test code as possible.
  def test_call_service_one_level
    s_client = ServiceClient.new
    h = Hash.new
    h[:num1] = "5"
    h[:num2] = "5"
    out = s_client.run_service(@url,@user,@pass,"pub.math:addInts",h)
    assert_equal "10",out[:value]
  
  end

  def test_call_service_multi_dim
    top = Hash.new
    add = Hash.new
    sub = Hash.new
    mult = Hash.new

    add[:number1] = "5"
    add[:number2] = "5"
    add[:result] = ""

    sub[:number1] = "10"
    sub[:number2] = "6"
    sub[:result] = ""

    mult[:nubmer1] = ""
    mult[:number2] = ""
    mult[:product] = ""

    top[:numbersToSum] = add
    top[:numbersToSuptract] = sub
    top[:numbersToMultiply] = mult
    input = Hash.new
    input[:InputNumbers] = top
    #execute the service
    output = @svc_client.run_service(@url,@user,@pass,"utils.services:docTesterDocOut",input)

    #verify the output
    r_top = output[:outputNumbers]
    r_add = r_top[:numbersToSum]
    r_sub = r_top[:numbersToSuptract]
    r_mult = r_top[:numbersToMultiply]

    assert_equal "5",r_add[:number1]
    assert_equal "5",r_add[:number2]
    assert_equal "10", r_add[:result]
    assert_equal "10", r_sub[:number1]
    assert_equal "6", r_sub[:number2]
    assert_equal "4", r_sub[:result]
    assert_equal "10",r_mult[:number1]
    assert_equal "4",r_mult[:number2]
    assert_equal "40",r_mult[:product]
  end
end