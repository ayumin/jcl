require 'jcl'

describe Jcl::Job, "aaa" do
  it "case 1" do
    job = Jcl::Job.new('hoge')
    job.name.should eql "hoge"
    job.param.should be_empty
    job.command.should == 'JOB'
  end
  it "case 2" do
    job = Jcl::Job.new('hoge','ruby=fun')
    job.name.should == 'hoge'
    job.param.should == {'ruby'=>'fun'}
    job.to_jcl.should eql "//hoge JOB ruby=fun"
  end
  it "case 3" do
    job = Jcl::Job.new 'hoge', 'ruby=fun'
    job.add_param('perl=good')
    job.param.should == {'ruby'=>'fun','perl'=>'good'}
    job.to_jcl.should eql "//hoge JOB ruby=fun,perl=good"
  end

  it "should add some step(s)" do
    job = Jcl::Job.new 'hoge', 'ruby=fun'
    s1 = Jcl::Step.new('fuga')
    job.add_step s1
    job.steps[0].should equal s1
    job.steps[1].should be_nil
  end

  it "should not append some DD to step" do
    job = Jcl::Job.new 'hoge', 'ruby=fun'
    d1 = Jcl::Dd.new('fuga')
    lambda{ job.add_step(d1) }.should raise_error
  end
end
describe Jcl::Step, "that created without Job" do
  it "should have name" do
    step = Jcl::Step.new('foo')
    step.name.should eql 'foo'
    step.param.should be_empty
    step.command.should eql 'EXEC'
  end
  it "should have params when given some param-set" do
    step = Jcl::Step.new('foo','ruby=fun')
    step.name.should eql 'foo'
    step.param.should == {'ruby'=>'fun'}
  end
end
describe Jcl::Dd, "that created without Job or Step" do
  it "should have name" do
    dd = Jcl::Dd.new 'bar'
    dd.name.should eql 'bar'
    dd.param.should be_empty
    dd.command.should eql 'DD'
  end
end
