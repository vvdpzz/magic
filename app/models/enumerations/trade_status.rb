class TradeStatus < EnumerateIt::Base
  associate_values(
    :normal  => 0,
    :success => 1,
    :return => 2
  )
end