# frozen_string_literal: true

module Web
  class ApplicationController < ::ApplicationController
    include AuthManagement

    allow_browser versions: :modern
  end
end
