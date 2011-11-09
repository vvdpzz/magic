class TradeType < EnumerateIt::Base
  associate_values(
    :ask => 0,
    :answer => 1,
    :accept => 2
  )
end