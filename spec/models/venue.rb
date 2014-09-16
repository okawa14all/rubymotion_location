describe 'Venue' do

  before do
  end

  after do
  end

  it 'should create instance' do
    Venue.create.is_a?(Venue).should == true
  end
end
