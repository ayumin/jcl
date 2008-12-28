# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'string'

describe String do
  it "should convert single param-set that has nil value" do
    string = "hoge"
    string.parametize.should == {'hoge'=> nil}
  end

  it "should convert single param-set pars to hash" do
    string = "ruby=fun"
    string.parametize.should == {'ruby'=>'fun'}
  end

  it "should convert multiple param-set pars to hash" do
    string = "ruby=fun,perl=good"
    string.parametize.should == {'ruby'=>'fun','perl'=>'good'}
  end

  it "should convert param-set that have 'VOL=SER'" do
    string = "VOL=SER=TEST9R,ruby=fun"
    string.parametize.should == {'VOL_SER'=>'TEST9R','ruby'=>'fun'}
  end
end

