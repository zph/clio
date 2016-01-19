defmodule Syslog do

  # Syslog Parsing
  # accepts a large chunk of data from Heroku, multi-lines
  def msg_to_lines("", acc) do acc end
  def msg_to_lines(tail, acc \\ []) do
    [len, full] = String.split(tail, " ", parts: 2)
    {line, rest} = String.split_at(full, String.to_integer(len))
    msg_to_lines(rest, acc ++ [String.strip(line)])
  end

"""
https://tools.ietf.org/html/rfc5424
6.  Syslog Message Format

   The syslog message has the following ABNF [RFC5234] definition:

      SYSLOG-MSG      = HEADER SP STRUCTURED-DATA [SP MSG]

      HEADER          = PRI VERSION SP TIMESTAMP SP HOSTNAME
                        SP APP-NAME SP PROCID SP MSGID
      PRI             = "<" PRIVAL ">"
      PRIVAL          = 1*3DIGIT ; range 0 .. 191
      VERSION         = NONZERO-DIGIT 0*2DIGIT
      HOSTNAME        = NILVALUE / 1*255PRINTUSASCII

      APP-NAME        = NILVALUE / 1*48PRINTUSASCII
      PROCID          = NILVALUE / 1*128PRINTUSASCII
      MSGID           = NILVALUE / 1*32PRINTUSASCII

      TIMESTAMP       = NILVALUE / FULL-DATE "T" FULL-TIME
      FULL-DATE       = DATE-FULLYEAR "-" DATE-MONTH "-" DATE-MDAY
      DATE-FULLYEAR   = 4DIGIT
      DATE-MONTH      = 2DIGIT  ; 01-12
      DATE-MDAY       = 2DIGIT  ; 01-28, 01-29, 01-30, 01-31 based on
                                ; month/year
      FULL-TIME       = PARTIAL-TIME TIME-OFFSET
      PARTIAL-TIME    = TIME-HOUR ":" TIME-MINUTE ":" TIME-SECOND
                        [TIME-SECFRAC]
      TIME-HOUR       = 2DIGIT  ; 00-23
      TIME-MINUTE     = 2DIGIT  ; 00-59
      TIME-SECOND     = 2DIGIT  ; 00-59
      TIME-SECFRAC    = "." 1*6DIGIT
      TIME-OFFSET     = "Z" / TIME-NUMOFFSET
      TIME-NUMOFFSET  = ("+" / "-") TIME-HOUR ":" TIME-MINUTE


      STRUCTURED-DATA = NILVALUE / 1*SD-ELEMENT
      SD-ELEMENT      = "[" SD-ID *(SP SD-PARAM) "]"
      SD-PARAM        = PARAM-NAME "=" %d34 PARAM-VALUE %d34
      SD-ID           = SD-NAME
      PARAM-NAME      = SD-NAME
      PARAM-VALUE     = UTF-8-STRING ; characters '"', '\' and
                                     ; ']' MUST be escaped.
      SD-NAME         = 1*32PRINTUSASCII
                        ; except '=', SP, ']', %d34 (")

      MSG             = MSG-ANY / MSG-UTF8
      MSG-ANY         = *OCTET ; not starting with BOM
      MSG-UTF8        = BOM UTF-8-STRING
      BOM             = %xEF.BB.BF
      UTF-8-STRING    = *OCTET ; UTF-8 string as specified ; in RFC 3629

      OCTET           = %d00-255
      SP              = %d32
      PRINTUSASCII    = %d33-126
      NONZERO-DIGIT   = %d49-57
      DIGIT           = %d48 / NONZERO-DIGIT
      NILVALUE        = "-"
      """

  def parse_structured_data(data) do
    cond do
      String.starts_with?(data, "APP_METRIC") -> %{type: :metric, text: metric_line(data)}
      true -> %{type: :other, text: data}
    end
  end

  def metric_line(str) do
    [_, match] = Regex.run(~r/APP_METRIC ({.*})/, str)
    Poison.Parser.parse!(match)
  end

  def parse_line(line) do
    "<190>1 2016-01-17T03:26:12.297505+00:00 host app web.1 - source=rack-timeout id=fa9f7998-7d41-4286-82c4-4e332fbd8b8e wait=17ms timeout=20000ms service=43ms state=completed"
    [pri_ver_raw, time, host, app, proc, msgid, data] = String.split(line, " ", parts: 7)

    [_, x, y] = Regex.scan(~r/<(\d{1,3})>(\d)/, pri_ver_raw) |> List.first

    %{pri: x, version: y, timestamp: time, hostname: host, app_name: app, procid: proc, msgid: msgid, structured_data: parse_structured_data(data)}

  end

  def msg_to_parsed_lines(txt) do
    msg_to_lines(txt)
    |> Enum.map(&parse_line/1)
  end

end
