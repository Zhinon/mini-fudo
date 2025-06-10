require "product_creation_worker"
require "message_broker"

describe Workers::ProductCreationWorker do
  let(:worker) { described_class.new }
  let(:now) { Time.now.to_i }

  def product_count
    DB[:products].count
  end

  before do
    allow(Time).to receive(:now).and_return(Time.at(now))
    allow(worker).to receive(:sleep)
  end

  it "inserts new product if it does not exist" do
    data = {
      "name" => "Coca-Cola 500ml",
      "user_id" => 1,
      "timestamp" => now - 1
    }

    expect {
      worker.process(data)
    }.to change { product_count }.by(1)
  end

  it "does not insert if product already exists" do
    DB[:products].insert(name: "Coca-Cola 500ml", user_id: 2)

    data = {
      "name" => "Coca-Cola 500ml",
      "user_id" => 2,
      "timestamp" => now - 1
    }

    expect {
      worker.process(data)
    }.not_to change { product_count }
  end

  it "waits if timestamp is in the future" do
    data = {
      "name" => "Coca-Cola 500ml",
      "user_id" => 3,
      "timestamp" => now - 3
    }

    expect(worker).to receive(:sleep).with(2)
    worker.process(data)
  end
end
