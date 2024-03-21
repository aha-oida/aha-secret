class AhaApp < Sinatra::Base
  get "/" do
    erb :index
  end
end
