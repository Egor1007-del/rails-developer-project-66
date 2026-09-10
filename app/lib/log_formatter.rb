class LogFormatter
  class << self
    def format(output, language)
      parsed_output = parse(output)

      files_with_offenses =
        case language.to_s
        when "ruby"
          rubocop_files(parsed_output)
        when "javascript"
          eslint_files(parsed_output)
        else
          []
        end

      offense_count =
        case language.to_s
        when "ruby"
          rubocop_offense_count(parsed_output)
        when "javascript"
          eslint_offense_count(parsed_output)
        else
          0
        end

      {
        files_with_offenses: files_with_offenses,
        offense_count: offense_count
      }
    end

    private

    def parse(output)
      return {} if output.blank?

      JSON.parse(output)
    rescue JSON::ParserError
      {}
    end

    def rubocop_files(parsed_output)
      return [] unless parsed_output.is_a?(Hash)

      parsed_output
        .fetch("files", [])
        .select { |file| file.fetch("offenses", []).any? }
    end

    def eslint_files(parsed_output)
      return [] unless parsed_output.is_a?(Array)

      parsed_output.filter_map do |file|
        messages = file.fetch("messages", [])

        next if messages.empty?

        {
          "path" => file["filePath"],
          "offenses" => messages.map do |message|
            {
              "message" => message["message"],
              "cop_name" => message["ruleId"] || "ESLint",
              "location" => {
                "start_line" => message["line"],
                "start_column" => message["column"]
              }
            }
          end
        }
      end
    end

    def rubocop_offense_count(parsed_output)
      return 0 unless parsed_output.is_a?(Hash)

      parsed_output.dig("summary", "offense_count") || 0
    end

    def eslint_offense_count(parsed_output)
      return 0 unless parsed_output.is_a?(Array)

      parsed_output.sum do |file|
        file.fetch("messages", []).count
      end
    end
  end
end
