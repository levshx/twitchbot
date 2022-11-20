import core/botcore
import os, strutils

var
  BotNick = "levshxbot"
  OAuthKey = readFile(getAppDir() / "oauth.key") # create file with bot.exe > oauth.key 
  Chanel = "levshx"
  badwords_answers = readFile(getAppDir() / "badwordsNotice.txt").splitLines()
  
  bot = newTwitchBot(BotNick, OAuthKey, Chanel)

proc getSocialRating(nick: string): int =
  return nick.len

proc helpCallback(nick: string, args: seq[string]) =
  bot.sendMessage("@"&nick&", комманды тут: https://levshx.github.io/twitch-bot/")

proc newChatterCallback(nick: string): void =
  bot.sendMessage("@"&nick&", добро пожаловать в ЧААТ")

proc ratingCallback(nick: string, args: seq[string]) = 
  bot.sendMessage("@"&nick&", очки социального рейтинга: "& $(getSocialRating(nick)*10))

proc badwordCallback(nick:string) =
  bot.sendMessage("@" & nick & ", " & badwords_answers.sample)
     
proc subCallback(nick:string) =
  bot.sendMessage("@"&nick&", СПОСИБО!! ЗА ПОДПИСКУ!! НО Я НЕ ЗНАЮ КАК СНЯТЬ ЭТИ ДЕНЬГИ!!!, НО ВСЁ РАВНО СПОСИИИБООО!!")

proc resubCallback(nick:string, month: int) =
  bot.sendMessage("@"&nick&" профессианально оформил РЕСУБ!! В теме уже: "& $month & " month")

proc cronCallback() = 
  bot.sendMessage("Мессага из крона каждые 5 минут")

proc main(): void =
  var helper: Trigger_Command
  helper.reg = re"^ *!help *$"
  helper.callback = helpCallback

  var rating: Trigger_Command
  rating.reg = re"^ *!rating *$"
  rating.callback = ratingCallback

  var badWords: Trigger_Words
  badWords.words = readFile(getAppDir() / "badwords.txt").splitLines()
  badWords.callback = badwordCallback

  var newChatter: Trigger_New_Chatter
  newChatter.callback = newChatterCallback

  var sub: Trigger_Sub
  sub.callback = subCallback

  var resub: Trigger_Resub
  resub.callback = resubCallback

  var cron: Trigger_Cron
  cron.timeout = initDuration(minutes = 5)
  cron.last_time = now()
  cron.callback = cronCallback

  bot.triggers.command.add(helper)
  bot.triggers.command.add(rating)
  bot.triggers.word.add(badWords)
  bot.triggers.sub.add(sub)
  bot.triggers.resub.add(resub)
  bot.triggers.newChatter.add(newChatter)
  bot.triggers.cron.add(cron)
  
  bot.logEnable(true)

  while not bot.connect():
    bot.logLine("try reconnect")

  while true:
    bot.step()

main()