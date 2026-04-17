Y# ============================================================
#  SENTIMENTIQ — Multi-Domain Sentiment Analysis Dashboard
#  Datasets: IMDB · Twitter · Amazon · Reddit · News · Support
#  NLP: tidytext, syuzhet, NRC / AFINN / Bing lexicons
#
#  NEW v2: UX Polish + Intelligence Layer
#  ✦ Animated KPI counters
#  ✦ Step-by-step progress bar
#  ✦ Guided onboarding tour
#  ✦ Keyboard shortcuts
#  ✦ Per-document word highlighter
#  ✦ Lexicon disagreement detection
#  ✦ Negation pattern flagging
#  ✦ Confusion matrix + F1 metrics
#  ✦ Explainability tab with LIME-style word importance
# ============================================================

suppressPackageStartupMessages({
  library(shiny); library(shinydashboard); library(shinyjs)
  library(shinycssloaders); library(ggplot2); library(dplyr)
  library(tidyr); library(tidytext); library(stringr)
  library(wordcloud2); library(syuzhet); library(scales)
  library(DT); library(forcats); library(ggridges)
})

# ══════════════════════════════════════════════════════════════
#  SECTION 1 — BUILT-IN DATASETS
# ══════════════════════════════════════════════════════════════

make_dataset <- function(texts, pos_frac = 0.40, neg_frac = 0.40) {
  n <- length(texts); n_pos <- floor(n * pos_frac)
  n_neg <- floor(n * neg_frac); n_neu <- n - n_pos - n_neg
  tibble(id = seq_len(n), text = texts,
         label = c(rep("Positive", n_pos), rep("Negative", n_neg), rep("Neutral", n_neu)))
}

DS_IMDB <- make_dataset(c(
  "This movie was absolutely brilliant. The acting was superb and the storyline kept me hooked.",
  "Masterpiece of modern cinema. Every frame is a work of art.",
  "Surprisingly good! I had low expectations but was blown away.",
  "A heartwarming story that will make you laugh and cry.",
  "Incredible performances all around. A must-watch for any film lover.",
  "Genuinely entertaining from start to finish. Great pacing.",
  "A hidden gem! Deeply moving and beautifully shot.",
  "Captivating and thought-provoking. Left me thinking for days.",
  "Absolutely loved every minute. Will definitely watch again.",
  "One of the best films of the decade without a doubt.",
  "A delightful adventure for the whole family.",
  "Stunning visuals paired with an emotional score. Breathtaking.",
  "Hilarious and charming from the opening scene.",
  "Outstanding direction and career-best performances.",
  "An emotional rollercoaster that I highly recommend.",
  "Beautifully crafted with stunning attention to detail.",
  "A profound meditation on loss and redemption.",
  "Funny, touching and completely original.",
  "A near-perfect film in every respect.",
  "Bold, daring and unlike anything I have seen before.",
  "The chemistry between the leads is electric and convincing.",
  "Genuinely moved me. A rare and special film.",
  "Every performance is note-perfect. Exceptional ensemble.",
  "A powerful story told with grace and nuance.",
  "Refreshingly original take on a familiar genre.",
  "Warm, witty and wonderfully entertaining.",
  "Intelligent and layered with outstanding performances.",
  "Funny, heartfelt and surprisingly profound.",
  "Exceptional filmmaking with real emotional depth.",
  "A triumphant return to form for the director.",
  "Visually stunning with a gripping narrative.",
  "One of the most beautiful films I have ever seen.",
  "Brilliant satire that is both funny and sharp.",
  "Sweet, funny and thoroughly enjoyable.",
  "A modern classic that deserves all the praise it receives.",
  "Superb thriller that kept me on the edge of my seat.",
  "Touching family drama with outstanding performances.",
  "A cinematic event that demands to be seen on the big screen.",
  "Genuinely surprising and deeply satisfying.",
  "A mature and confident piece of filmmaking.",
  "Heartbreakingly beautiful and unforgettable.",
  "Smartly written with great comedic timing.",
  "An absolute triumph of independent cinema.",
  "Perfectly paced with not a single wasted scene.",
  "Warm performances elevate an already great script.",
  "Terrible film. Waste of time and money. The plot made no sense whatsoever.",
  "Boring and predictable. I fell asleep halfway through.",
  "The worst acting I have ever seen in my life. Cringe-worthy scenes throughout.",
  "Mediocre at best. The special effects could not save a weak script.",
  "I cannot believe how bad this was. Complete disappointment.",
  "The director clearly had no idea what they were doing.",
  "Not worth the ticket price. Felt like a student film.",
  "Dull characters and zero chemistry between the leads.",
  "Confusing plot with too many loose ends. Very unsatisfying.",
  "Overrated garbage. The hype around this film is baffling.",
  "The screenplay was lazy and full of cliches.",
  "Too slow and pretentious for my taste.",
  "The third act completely ruined what was building up nicely.",
  "Generic action movie with forgettable characters.",
  "Poorly written dialogue and terrible pacing.",
  "Too many plot holes to take seriously.",
  "The CGI looked outdated and cheapened the whole experience.",
  "Disappointing sequel that fails to live up to the original.",
  "Felt like a cash-grab with no real artistic vision.",
  "Messy narrative that tries to do too much at once.",
  "Style over substance. Pretty but empty.",
  "Repetitive and overly long. Should have been an hour shorter.",
  "The villain is cartoonishly evil and one-dimensional.",
  "A complete mess from beginning to end.",
  "Lowest common denominator filmmaking. Avoid.",
  "Flat characters and a predictable resolution.",
  "The humour felt forced and out of place.",
  "Soulless franchise entry designed purely for profit.",
  "Annoying protagonist that I could not root for.",
  "Fails on almost every level it attempts to achieve.",
  "Far too long and self-indulgent for its own good.",
  "The ending was a complete cop-out and very disappointing.",
  "Derivative and unoriginal. We have seen this all before.",
  "Painfully slow and pretentious. Not for me.",
  "Weak script propped up by the sheer charisma of its cast.",
  "Loud, chaotic and completely mindless entertainment.",
  "Too reliant on CGI with little substance beneath.",
  "The romance subplot felt completely shoehorned in.",
  "Clicheed and predictable from the very first scene.",
  "A dreary slog that tries the viewers patience.",
  "Mediocre special effects in a forgettable blockbuster.",
  "Action scenes are impressive but the story is hollow.",
  "Formulaic romance with no surprises.",
  "An average movie. Some parts were good but others dragged on too long.",
  "Not my cup of tea but I can see why others enjoy it.",
  "Has its moments but overall falls short of expectations.",
  "Some good ideas that were never fully developed.",
  "A passable film but you will not remember it by morning.",
  "Neither particularly good nor particularly bad.",
  "An inoffensive if unremarkable piece of genre filmmaking.",
  "Watchable but not something I would seek out again.",
  "Decent enough for a lazy afternoon.",
  "Perfectly average in every way.",
  "Some nice cinematography but the story is thin.",
  "A middle-of-the-road effort that neither impresses nor offends.",
  "Fine but forgettable.",
  "Not great not terrible just there.",
  "Could have been much better with a stronger script.",
  "Acceptable but the competition is stronger.",
  "Competent but completely unremarkable.",
  "Mediocre pacing but the cast does their best.",
  "Adequate for one viewing, nothing more.",
  "Occasionally interesting but mostly pedestrian.",
  "Meets the minimum bar and nothing beyond.",
  "Passes the time without leaving any impression.",
  "Technically proficient but emotionally hollow.",
  "Neither offensive nor inspiring. Exists.",
  "The kind of film you watch on a plane and immediately forget.",
  "Solid craft undermined by a deeply unoriginal story."
))

DS_TWITTER <- make_dataset(c(
  "So excited for the new product launch today!! This is going to change everything",
  "Just tried the new AI feature and honestly it blew my mind. Never going back.",
  "Customer support actually helped me today pleasantly surprised! Five stars.",
  "This new update is exactly what I needed. Dev team absolutely killed it.",
  "Cannot believe how fast the app loads now. Whoever optimised this deserves a raise.",
  "Just donated to the relief fund. Feeling hopeful about what communities can achieve together.",
  "Woke up to great news about the climate bill passing. A step in the right direction!",
  "My team just won the regional championship!! Months of practice finally paid off.",
  "Finally finished my dissertation!! Four years of work and it is done.",
  "Just booked tickets to Japan for next month. This is a dream come true.",
  "Shoutout to the bus driver who waited for me when I was running late. You are a legend.",
  "New season of my favourite show dropped and it is even better than I hoped.",
  "Got the promotion I have been working towards for two years. Hard work pays off.",
  "So grateful for friends who show up when things get hard.",
  "Local bakery on my street just won a national award. Go support them!",
  "Just finished my first 10K run! Never thought I could do this. Incredibly proud.",
  "Adopted a rescue dog today. Best decision of my life.",
  "Tech community rallied to help me debug a nasty issue in 20 minutes. Open source is beautiful.",
  "The new park renovation is stunning. Props to the city council for listening to residents.",
  "The coffee shop gave me a free pastry for my birthday. I love this city.",
  "This app is broken again and their support has not replied in 3 days. Absolutely fed up.",
  "Cannot believe how slow this website is. There is no excuse for this performance.",
  "Just got scammed by a fake online store. Lost money and am furious. DO NOT BUY FROM THEM.",
  "The airline lost my luggage AGAIN. Third time in two years. Never flying with them.",
  "Waited 45 minutes for delivery only to receive the wrong order. Unacceptable.",
  "My landlord has still not fixed the heating after two weeks of complaints. Disgusting.",
  "The new update completely broke a feature I use every day. No warning, no changelog.",
  "Politicians promising things they never deliver. Same story every single election.",
  "Traffic is a nightmare again. Two hours to travel six miles. This city is a joke.",
  "Bought a new phone that stopped working after three days. Customer service offered nothing.",
  "Social media algorithm keeps showing me content I flagged as irrelevant.",
  "Another data breach and another set of weak apologies. Companies never actually change.",
  "Cancelled my subscription after five years. Quality dropped dramatically and price went up.",
  "Watched three hours of news and now I need a week off from reality.",
  "Gym raised prices for the third time while the equipment keeps breaking.",
  "Recruiter ghosted me after four interview rounds. A simple email would have been enough.",
  "Streaming platform removed the show I was halfway through with zero notice. Ridiculous.",
  "Ordered a birthday cake a week in advance and it never arrived. Ruined the whole event.",
  "Local council approved another car park instead of green space. Failure of leadership.",
  "Missed my connecting flight because of a ten-minute delay at security. System is broken.",
  "Just saw the election results come in. Going to be an interesting few months.",
  "The app updated overnight and I am still figuring out where everything moved to.",
  "Weather forecast was completely wrong again.",
  "My gym changed its opening hours and nobody sent a notification.",
  "Read a long thread today about housing affordability. Lots of different perspectives.",
  "Watched the debate. People will have very different views on how that went.",
  "New policy announced today. The details are complicated and experts seem divided.",
  "Network was slow this morning. Back to normal now apparently.",
  "The restaurant changed its menu. Some things I liked are gone, some new things look interesting.",
  "City road works started again on my commute route.",
  "Supermarket rearranged the entire layout. Will take me a month to readjust.",
  "Phone battery died unexpectedly in the middle of the day.",
  "Parcel arrived a day late but still within the delivery window.",
  "Meeting got moved to a different time. Calendar updated, no big deal.",
  "Downloaded the new software version. Looks slightly different but functions about the same.",
  "Bus was four minutes late this morning. Made it to work on time anyway.",
  "Tried a new coffee shop today. It was okay, nothing special.",
  "The gym was a bit busier than usual for a Tuesday.",
  "Film got mixed reviews it seems. Some people loved it, others less so.",
  "Weather is grey again but at least it is not raining."
))

DS_AMAZON <- make_dataset(c(
  "Absolutely love this product! Works exactly as described and arrived two days early.",
  "Best purchase I have made this year. Exceeded all my expectations. Five stars.",
  "Incredible build quality. You can tell this was made with care. Highly recommend.",
  "This gadget has completely changed my morning routine. Cannot imagine life without it now.",
  "Packaging was beautiful and the product itself is even better in person.",
  "Works perfectly straight out of the box. Setup took less than five minutes.",
  "Outstanding value for the price. Paid budget cost for premium quality.",
  "My third purchase from this brand and they never disappoint. Loyal customer for life.",
  "The customer service team sorted my query within an hour. Genuinely impressive.",
  "Bought this as a gift and the recipient was absolutely thrilled. Will buy again.",
  "Solid, reliable and does exactly what it says on the tin. No gimmicks, just works.",
  "Delivery was lightning fast and the item was packaged immaculately. Zero complaints.",
  "This replaced my old unit and is clearly a generation ahead in every way.",
  "Easy to assemble, intuitive to use and looks great on my desk.",
  "Used this daily for three months and it has not missed a beat. Very impressed.",
  "Remarkable battery life. Charges in an hour and lasts all day without issue.",
  "Fits perfectly, feels premium and works flawlessly. Exactly what I needed.",
  "The instructions were clear, the build was simple and the result is excellent.",
  "Noticed a significant improvement in performance the very first day.",
  "Five stars without hesitation. Best version of this product I have owned.",
  "Completely fell apart within two weeks of light use. Utter rubbish.",
  "Arrived damaged and the return process has been a nightmare. Still not resolved.",
  "Absolutely nothing like the photos. The colour, size and quality are all wrong.",
  "Stopped working after a month. Company refused a refund and blamed user error.",
  "The smell is overpowering and gave me a headache the first three times I used it.",
  "Instructions are incomprehensible and no customer support available at weekends.",
  "Cheap plastic everywhere. Feels like it cost a tenth of what I paid.",
  "The battery drains in under two hours despite advertising twelve hour life.",
  "Ordered a size medium and received an extra small with no option to exchange.",
  "Sent the wrong item twice now. Customer service apologised but nothing was fixed.",
  "Would not turn on at all out of the box. Contacted support and still waiting two weeks later.",
  "Completely overpriced for what you get. Found the same product cheaper elsewhere.",
  "The clip broke on first use. Returned it immediately. Shocking quality control.",
  "Loud, inefficient and nothing like the quiet motor advertised. Very disappointed.",
  "Leaked all over my bag within 24 hours of first use. What a waste of money.",
  "Returned it after two days. The material was scratchy and caused irritation.",
  "Arrived damaged. Would not recommend to anyone.",
  "Absolutely terrible quality for the price point. Avoid.",
  "Broke immediately and getting a replacement has been an ordeal.",
  "Misleading product listing. What arrived was completely different.",
  "Works as described but the design could be more intuitive.",
  "Good quality overall though the colour is slightly different from the photos.",
  "Decent product for the price. A few minor niggles but nothing deal-breaking.",
  "Arrived on time and functions correctly. Nothing spectacular but does the job.",
  "Reasonable quality for an entry-level product. Meets basic expectations.",
  "It is fine. Not the best I have used but not the worst either.",
  "Solid product with one or two areas that could be improved in a future version.",
  "Adequate for everyday use. Heavy users might want to look at premium options.",
  "Packaging was excessive but the product itself is fine.",
  "Battery life is acceptable. Not as long as claimed but not terrible either.",
  "Would be four stars if the app integration worked more reliably.",
  "Good for the price. Would not buy at full price but excellent on sale.",
  "Average product that does what it needs to do. No more no less.",
  "Does the job well enough. Probably will not buy again but have no complaints.",
  "Functional but uninspiring. Gets the job done.",
  "Nothing wrong with it but nothing exciting either.",
  "Meets expectations set by the price point. No surprises.",
  "Standard product, standard experience.",
  "Neither impressed nor disappointed. Exactly as expected.",
  "Serviceable. That is the most I can say."
))

DS_REDDIT <- make_dataset(c(
  "Finally told my therapist the full truth today. Feels like putting down a weight I did not know I was carrying.",
  "Six months sober today. Genuinely did not think I could do this. Sharing here because you all believed in me first.",
  "The meditation practice people here recommended has genuinely helped my anxiety. Thank you.",
  "My doctor adjusted my medication and I feel like myself again for the first time in years.",
  "My support group met last night and I left feeling less alone than I have in months.",
  "I set a boundary with a family member today and they actually respected it. Progress.",
  "Managed to get out of bed, shower and eat breakfast all before noon. Tiny win but I will take it.",
  "Journaling every day for thirty days straight. Starting to spot patterns in my own thinking.",
  "Sleep has improved dramatically since I stopped looking at my phone before bed.",
  "Completed my first week of therapy homework. It was uncomfortable but I can feel the change.",
  "Told a friend I was struggling and they showed up at my door with food. I forgot people could do that.",
  "Applied for a job today. First time I have felt excited about the future in a long time.",
  "My anxiety was loud today but I still did the thing anyway. That counts.",
  "Three years since my lowest point. I am still here and I am genuinely grateful for that.",
  "Started volunteering at a community garden. Getting my hands in the soil is strangely healing.",
  "Reached out to an old friend I had been avoiding. We talked for two hours like no time had passed.",
  "My therapist told me I have made more progress than I realise. I am choosing to believe her today.",
  "Took a personal day to actually rest, not to recover from anything specific. It helped.",
  "I finally understand what people mean when they say self-compassion is not weakness.",
  "Shared my diagnosis with my manager and they were more supportive than I ever imagined.",
  "Having one of those days where getting out of bed felt impossible and I still have not managed it.",
  "The intrusive thoughts are particularly loud this week and I am exhausted from arguing with them.",
  "Cancelled plans again. I know my friends understand but the shame is still awful.",
  "Relapsed after eight months and I do not even know how to tell the people who were proud of me.",
  "Cannot stop crying and do not know why. Just needed to say it somewhere.",
  "Anxiety attack in a supermarket today. Had to abandon my trolley and just sit in the car.",
  "The medication is not working and my next appointment is five weeks away.",
  "My brain keeps convincing me that nothing will ever improve.",
  "Therapy is making me dig up things I spent years burying and right now it just feels worse.",
  "I have been isolating for two weeks and I know it is making things worse but I cannot stop.",
  "Missed work again. Boss is starting to notice and I have no explanation.",
  "Woke up at 3am with my heart racing for no reason and could not get back to sleep.",
  "Said I was fine again when someone asked. I do not know how to say anything else.",
  "The weight of this week is enormous. Barely functioning.",
  "Tried the breathing exercises and they did not help today. Feels like failing.",
  "The darkness is really bad right now. Not okay.",
  "Every day feels the same and I am running out of reasons to keep trying.",
  "Shutdown again. Cannot respond to anyone. Silence feels like the only option.",
  "Body feels heavy, mind feels empty. Nothing in between.",
  "Zero energy. Even the things I used to love feel pointless.",
  "Checking in because it helps to have somewhere to say things are hard right now.",
  "Rough patch lately but I have been through rough patches before.",
  "Not great but not as bad as last month. That feels like something.",
  "Finding it hard to know if what I am feeling is normal or something to worry about.",
  "Some days are better than others. Today was a middle day.",
  "Struggling but still doing the small things. Showing up even when it is hard.",
  "In that grey zone where nothing is catastrophic but nothing feels good either.",
  "Tired in a way that sleep does not fix but trying to keep perspective.",
  "Managing day by day. Some hours are better than others.",
  "On a waiting list for therapy. Using the coping tools I already know until then.",
  "Just here to read and feel a bit less alone tonight.",
  "Processing something difficult. Not ready to talk about it yet.",
  "Keeping my routine even when it feels hollow.",
  "Learning that healing is not linear. Today is proof of that.",
  "Day by day. That is all I can do right now.",
  "Holding on. That is enough for today.",
  "Not flourishing but not drowning either.",
  "Somewhere in the middle. Trying to stay there.",
  "Showing up for myself even when showing up is the hardest thing.",
  "One more day. That is what I can manage right now."
))

DS_NEWS <- make_dataset(c(
  "Economy shows strongest growth in a decade as unemployment falls to record low",
  "Scientists announce breakthrough cancer treatment with ninety percent success rate in trials",
  "City council approves landmark green energy plan reducing emissions by half within five years",
  "Local charity raises record amount to house homeless families ahead of winter",
  "New education initiative delivers free school meals to two hundred thousand children",
  "Tech company creates ten thousand jobs in rural communities with new development hub",
  "Historic peace agreement signed ending decade-long regional conflict",
  "Vaccine programme credited with eliminating disease that affected millions annually",
  "Community fundraiser rebuilds flood-damaged homes in under three weeks",
  "Award-winning young inventor creates clean water solution for remote villages",
  "Renewable energy now powers over sixty percent of national grid for first time",
  "New legislation gives workers the right to disconnect from work outside office hours",
  "Study finds sharp rise in life expectancy linked to improved primary healthcare access",
  "Arts funding increase sees hundreds of new cultural venues open across country",
  "Public transport overhaul slashes commute times for millions of daily passengers",
  "Pioneering surgery restores sight to patients previously told they would never see again",
  "Reforestation project plants one billion trees surpassing original target by forty percent",
  "Youth employment programme places record number of graduates in permanent roles",
  "International aid effort delivers critical supplies to disaster zone within forty-eight hours",
  "Research university opens free online courses to three million students in developing nations",
  "Inflation rises for sixth consecutive month pushing household costs to thirty-year high",
  "Hospital declares major incident as patient waiting times spiral out of control",
  "Government accused of cover-up following leaked documents on environmental damage",
  "Violent crime surges in capital as police funding faces deepest cuts in two decades",
  "Thousands of workers lose jobs as manufacturing giant announces plant closures",
  "Wildfire destroys fifty thousand hectares in worst recorded season for the region",
  "Corruption inquiry names senior officials in widespread public funds scandal",
  "Drug-resistant infection spreading in hospitals raising alarm among health authorities",
  "Housing crisis deepens as average rent increases thirty percent in a single year",
  "Cyber attack cripples national infrastructure leaving hospitals without systems for days",
  "Child poverty rate climbs to highest level in fifteen years report finds",
  "Food bank usage triples as cost of living crisis bites hardest for low income families",
  "River pollution levels deemed dangerous as illegal dumping cases triple in three years",
  "School closures continue as teacher shortage reaches critical levels across all regions",
  "Mass data breach exposes personal records of forty million citizens",
  "Climate scientists issue urgent warning as global temperatures exceed critical threshold",
  "Experts divided as nation braces for outcome of landmark vote",
  "New trade figures published showing mixed performance across different sectors",
  "Central bank holds interest rates following closely watched policy meeting",
  "Parliamentary debate on proposed legislation expected to continue into next week",
  "Regional election results show narrow margin with coalition talks now underway",
  "Government publishes consultation on proposed changes to planning regulations",
  "International summit concludes with joint statement on shared economic priorities",
  "Survey finds public opinion divided on new social welfare policy proposal",
  "Audit office releases annual report on public sector spending efficiency",
  "Health authority issues updated guidance on managing seasonal illness outbreaks",
  "Transport authority announces review of rural bus services following usage data",
  "Education board releases results of standardised testing across all schools",
  "New research suggests moderate link between screen time and sleep quality in teenagers",
  "Analysis shows mixed outcomes from three-year urban renewal programme",
  "Inquiry launched after irregularities found in regional infrastructure spending",
  "Officials warn of prolonged disruption as talks collapse without agreement",
  "Reports emerge of systemic failures in child protection services across three counties",
  "Campaigners condemn rollback of environmental protections as reckless and short-sighted",
  "Experts warn new bill will deepen inequality and harm the most vulnerable communities",
  "Investigation reveals years of unreported safety violations at major industrial sites",
  "Watchdog finds evidence of widespread financial misconduct in local authorities",
  "Thousands march in capital demanding action on unaffordable housing costs",
  "Flooding forces mass evacuation as emergency services struggle to cope with scale of disaster",
  "Elderly care homes facing closure as chronic underfunding reaches breaking point"
))

DS_SUPPORT <- make_dataset(c(
  "Resolved my issue in minutes! The agent was incredibly knowledgeable and patient.",
  "Best customer service experience I have ever had. Issue sorted first time, no follow-up needed.",
  "The support team went above and beyond. Refund processed within 24 hours, no questions asked.",
  "Agent stayed on the line until the problem was fully fixed. That is rare. Thank you.",
  "Follow-up email arrived exactly when promised and fully addressed my concerns.",
  "Incredibly fast response and the solution actually worked. Will keep using this service.",
  "Support rep understood my issue immediately and fixed it remotely in under ten minutes.",
  "The live chat was efficient, friendly and solved a problem I had been struggling with all week.",
  "First call resolution. No waiting, no transferring, no repeating myself. Perfect.",
  "Manager called me personally to apologise for a previous bad experience. I am impressed.",
  "Agent sent a follow-up tutorial specifically tailored to my setup. Genuinely helpful.",
  "Refund arrived before I even got the confirmation email. Incredibly smooth process.",
  "Support portal is intuitive and my ticket was handled within the hour. Very happy.",
  "Callback arrived exactly on time and the agent had already read my previous tickets.",
  "Issue escalated appropriately and resolved within the promised timeframe.",
  "Knowledge base article they sent actually solved it. Clear, accurate and easy to follow.",
  "Never had to repeat my account details more than once. Small thing but really appreciated.",
  "Agent was empathetic and honest about what was possible. Trustworthy experience.",
  "Problem was fixed before the estimated resolution time. Came as a very pleasant surprise.",
  "Discount offered as apology for the inconvenience. Did not expect it but it was a nice touch.",
  "Been waiting five days for a response to a ticket marked urgent. Completely unacceptable.",
  "Transferred to three different departments and had to explain the issue every single time.",
  "The automated response said forty-eight hours. It has now been two weeks.",
  "Agent closed my ticket as resolved without actually fixing anything.",
  "Support line cuts off after twelve minutes on hold, every single time. Infuriating.",
  "Was told the issue would be escalated. Nobody ever called back. Zero follow-through.",
  "The chatbot loop is impossible to escape. I cannot get to a human being no matter what I try.",
  "Three agents gave me three completely different answers to the same question.",
  "Promised a refund within seven days. It has been six weeks and I have nothing.",
  "Agent was rude, dismissive and interrupted me repeatedly. Made a bad situation worse.",
  "The troubleshooting steps sent are identical to the ones that already failed.",
  "Ticket reopened after I replied and now sits at the back of the queue again.",
  "Asked for a supervisor and was told none were available and none would call back.",
  "Billing error happened twice in the same month despite being promised it was fixed.",
  "Email confirmation of my case was sent to the wrong address and now there is no record.",
  "Cannot get a refund because the system requires a receipt I was never sent.",
  "Support is only available on weekdays. The problem occurred Saturday morning.",
  "No one has taken ownership of this issue despite three separate tickets.",
  "Was promised a callback that never came. Three times now.",
  "The support portal went down while I was mid-submission and lost everything I typed.",
  "Response time was adequate though the solution required more back and forth than it should.",
  "Issue was resolved but took four days when the FAQ suggested it should be same day.",
  "Agent was polite but clearly working from a script and could not deviate when needed.",
  "Partial resolution provided. Main issue is fixed but a secondary problem remains.",
  "Response was prompt but the answer did not fully address what I asked.",
  "Acceptable service overall though I have experienced faster resolution elsewhere.",
  "Ticket was handled within the stated timeframe but the process felt overly complicated.",
  "Resolution was eventually reached but required more chasing from my side than ideal.",
  "Support was functional. Problem solved but no warmth or personalisation to the experience.",
  "Got there in the end. A few hiccups but the agent kept me informed throughout.",
  "Average experience. Met expectations but did not exceed them.",
  "The fix worked but the instructions were difficult to follow without technical background.",
  "Issue resolved on second attempt. First response missed the point but second was accurate.",
  "Adequate response time. Nothing exceptional but nothing to complain about.",
  "Standard support experience. Resolved within the window they stated.",
  "Polite and functional. Not memorable either way.",
  "Slower than I would have liked but ultimately resolved correctly.",
  "Used the self-service portal successfully. No agent interaction needed.",
  "Received standard troubleshooting steps. They worked, eventually.",
  "Competent if impersonal. Issue resolved without fanfare."
))

DATASETS <- list(
  imdb    = list(data=DS_IMDB,    label="IMDB Movie Reviews",         domain="Entertainment",  n=nrow(DS_IMDB),
                 icon="film", desc="115 labelled movie reviews spanning performances, direction, writing and overall quality."),
  twitter = list(data=DS_TWITTER, label="Twitter / X Posts",          domain="Social Media",   n=nrow(DS_TWITTER),
                 icon="twitter", desc="60 social media posts: product reactions, personal experiences, complaints and neutral observations."),
  amazon  = list(data=DS_AMAZON,  label="Amazon Product Reviews",     domain="E-Commerce",     n=nrow(DS_AMAZON),
                 icon="shopping-cart", desc="60 product reviews covering electronics and consumer goods from five-star praise to one-star complaints."),
  reddit  = list(data=DS_REDDIT,  label="Reddit Mental Health Posts", domain="Social Media",   n=nrow(DS_REDDIT),
                 icon="comments", desc="60 community posts from mental health forums covering recovery milestones, difficult periods and neutral check-ins."),
  news    = list(data=DS_NEWS,    label="News Article Headlines",     domain="Journalism",     n=nrow(DS_NEWS),
                 icon="newspaper", desc="60 news headlines across economics, health, environment, politics and crime."),
  support = list(data=DS_SUPPORT, label="Customer Support Tickets",   domain="Business / CRM", n=nrow(DS_SUPPORT),
                 icon="headset", desc="60 customer service interactions from retail, tech and telecoms sectors.")
)

# ══════════════════════════════════════════════════════════════
#  SECTION 2 — NLP PIPELINE (enhanced with negation + disagreement)
# ══════════════════════════════════════════════════════════════

# ── NEW: Negation detection ───────────────────────────────────
detect_negations <- function(text) {
  negation_patterns <- c(
    "not good","not great","not bad","not worth","not helpful","not working",
    "never again","no good","nothing special","cannot recommend","couldn't be worse",
    "not happy","not satisfied","not impressed","not recommend","don't like",
    "didn't work","doesn't work","wasn't good","isn't good","wasn't helpful"
  )
  text_lower <- tolower(text)
  found <- negation_patterns[sapply(negation_patterns, function(p) grepl(p, text_lower, fixed=TRUE))]
  if (length(found) > 0) paste(found, collapse="; ") else NA_character_
}

# ── NEW: Lexicon disagreement detection ──────────────────────
compute_disagreement <- function(df) {
  df %>%
    mutate(
      sign_afinn   = sign(score_afinn),
      sign_bing    = sign(score_bing),
      sign_nrc     = sign(score_nrc),
      sign_syuzhet = sign(score_syuzhet),
      n_positive   = (sign_afinn > 0) + (sign_bing > 0) + (sign_nrc > 0) + (sign_syuzhet > 0),
      n_negative   = (sign_afinn < 0) + (sign_bing < 0) + (sign_nrc < 0) + (sign_syuzhet < 0),
      disagreement = pmin(n_positive, n_negative),
      disagreement_flag = disagreement >= 2,
      disagreement_label = case_when(
        disagreement == 0 ~ "Unanimous",
        disagreement == 1 ~ "Slight",
        disagreement == 2 ~ "Moderate",
        disagreement >= 3 ~ "Strong"
      )
    )
}

# ── NEW: Per-document word highlighter ───────────────────────
highlight_text <- function(text, bing_words_df) {
  pos_words <- bing_words_df %>% filter(sentiment == "positive") %>% pull(word) %>% unique()
  neg_words <- bing_words_df %>% filter(sentiment == "negative") %>% pull(word) %>% unique()
  
  words <- unlist(strsplit(text, "(?<=[\\s])|(?=[\\s])", perl=TRUE))
  highlighted <- sapply(words, function(w) {
    clean <- tolower(gsub("[^a-zA-Z]", "", w))
    if (clean %in% pos_words) {
      paste0('<mark style="background:#16412a;color:#4ade80;padding:1px 3px;border-radius:3px;font-weight:600;">', w, '</mark>')
    } else if (clean %in% neg_words) {
      paste0('<mark style="background:#3f1212;color:#f87171;padding:1px 3px;border-radius:3px;font-weight:600;">', w, '</mark>')
    } else {
      w
    }
  })
  paste(highlighted, collapse="")
}

# ── CORE pipeline ─────────────────────────────────────────────
run_analysis <- function(texts, labels = NULL) {
  df_raw <- tibble(id = seq_along(texts), text = as.character(texts))
  if (!is.null(labels)) df_raw$label <- as.character(labels)
  
  df_raw <- df_raw %>%
    mutate(
      score_afinn   = get_sentiment(text, method = "afinn"),
      score_bing    = get_sentiment(text, method = "bing"),
      score_nrc     = get_sentiment(text, method = "nrc"),
      score_syuzhet = get_sentiment(text, method = "syuzhet"),
      predicted     = case_when(
        score_syuzhet > 0 ~ "Positive",
        score_syuzhet < 0 ~ "Negative",
        TRUE              ~ "Neutral"
      ),
      negation_found = sapply(text, detect_negations)
    )
  
  # Apply disagreement analysis
  df_raw <- compute_disagreement(df_raw)
  
  nrc_emotions <- get_nrc_sentiment(df_raw$text)
  df_raw <- bind_cols(df_raw, nrc_emotions)
  
  tokens <- df_raw %>%
    select(id, text) %>%
    unnest_tokens(word, text) %>%
    anti_join(stop_words, by = "word") %>%
    filter(str_detect(word, "^[a-z]+$"))
  
  afinn_words <- tokens %>% inner_join(get_sentiments("afinn"), by = "word")
  bing_words  <- tokens %>% inner_join(get_sentiments("bing"),  by = "word")
  word_freq   <- tokens %>% count(word, sort = TRUE)
  
  bigrams <- df_raw %>%
    select(id, text) %>%
    unnest_tokens(bigram, text, token = "ngrams", n = 2) %>%
    separate(bigram, c("w1","w2"), sep = " ") %>%
    filter(!w1 %in% stop_words$word, !w2 %in% stop_words$word,
           str_detect(w1,"^[a-z]+$"), str_detect(w2,"^[a-z]+$")) %>%
    count(w1, w2, sort = TRUE) %>%
    unite(bigram, w1, w2, sep = " ")
  
  # NEW: LIME-style word importance (AFINN contribution per document)
  word_importance <- afinn_words %>%
    count(id, word, value) %>%
    mutate(contribution = n * value) %>%
    arrange(id, desc(abs(contribution)))
  
  # NEW: Confusion matrix data (only when labels present)
  conf_data <- NULL
  metrics_data <- NULL
  if ("label" %in% names(df_raw)) {
    conf_data <- df_raw %>%
      count(label, predicted) %>%
      complete(label = c("Positive","Negative","Neutral"),
               predicted = c("Positive","Negative","Neutral"),
               fill = list(n = 0))
    
    classes <- c("Positive","Negative","Neutral")
    metrics_data <- lapply(classes, function(cls) {
      tp <- sum(df_raw$label == cls & df_raw$predicted == cls)
      fp <- sum(df_raw$label != cls & df_raw$predicted == cls)
      fn <- sum(df_raw$label == cls & df_raw$predicted != cls)
      precision <- ifelse((tp + fp) == 0, 0, tp / (tp + fp))
      recall    <- ifelse((tp + fn) == 0, 0, tp / (tp + fn))
      f1        <- ifelse((precision + recall) == 0, 0,
                          2 * precision * recall / (precision + recall))
      tibble(class=cls, precision=round(precision,3), recall=round(recall,3), f1=round(f1,3), tp=tp, fp=fp, fn=fn)
    })
    metrics_data <- bind_rows(metrics_data)
  }
  
  list(
    df=df_raw, tokens=tokens, afinn_words=afinn_words,
    bing_words=bing_words, word_freq=word_freq, bigrams=bigrams,
    word_importance=word_importance, conf_data=conf_data, metrics_data=metrics_data
  )
}

# ══════════════════════════════════════════════════════════════
#  SECTION 3 — THEME & COLOURS
# ══════════════════════════════════════════════════════════════

theme_dark_vit <- function() {
  theme_minimal(base_size=13) +
    theme(
      plot.background   = element_rect(fill="#0d1b2a", color=NA),
      panel.background  = element_rect(fill="#0d1b2a", color=NA),
      panel.grid.major  = element_line(color="#1e3a5f", linewidth=.4),
      panel.grid.minor  = element_blank(),
      axis.text         = element_text(color="#94a3b8"),
      axis.title        = element_text(color="#cbd5e1"),
      plot.title        = element_text(color="#f1f5f9", face="bold", size=15),
      plot.subtitle     = element_text(color="#94a3b8", size=11),
      legend.background = element_rect(fill="#0d1b2a", color=NA),
      legend.text       = element_text(color="#94a3b8"),
      legend.title      = element_text(color="#cbd5e1"),
      strip.text        = element_text(color="#38bdf8", face="bold")
    )
}

SENT_COLORS  <- c(Positive="#22c55e", Negative="#ef4444", Neutral="#f59e0b")
EMOTION_COLS <- c(anger="#ef4444",anticipation="#f97316",disgust="#a855f7",
                  fear="#6366f1",joy="#22c55e",sadness="#3b82f6",
                  surprise="#eab308",trust="#14b8a6")
DOMAIN_COLS  <- c("Entertainment"="#6366f1","Social Media"="#0ea5e9",
                  "E-Commerce"="#f97316","Journalism"="#14b8a6",
                  "Business / CRM"="#a855f7","User Upload"="#22c55e")

# ══════════════════════════════════════════════════════════════
#  SECTION 4 — CSS / JS HELPERS
# ══════════════════════════════════════════════════════════════

# Progress bar steps
PIPELINE_STEPS <- c(
  "Preparing corpus...",
  "Tokenising text...",
  "Running AFINN lexicon...",
  "Running Bing lexicon...",
  "Running NRC lexicon...",
  "Running Syuzhet scoring...",
  "Detecting negations...",
  "Computing disagreements...",
  "Extracting NRC emotions...",
  "Building word frequency...",
  "Extracting bigrams...",
  "Computing LIME importance...",
  "Finalising results..."
)

# ── Tour step definitions ─────────────────────────────────────
TOUR_STEPS_JS <- '
[
  {element: "#sidebarItemExpanded_home",   title: "Step 1: Home", content: "Select a built-in dataset or paste your own text here, then click Run Full Analysis."},
  {element: "#source",                     title: "Step 2: Data Source", content: "Choose from 6 labelled domains — IMDB, Twitter, Amazon, Reddit, News, or Support tickets."},
  {element: ".btn-primary",               title: "Step 3: Run Analysis", content: "Click here to start the full NLP pipeline across all four lexicons."},
  {element: "#sidebarItemExpanded_overview", title: "Step 4: Overview", content: "KPI cards and charts give a top-level summary of sentiment distribution."},
  {element: "#sidebarItemExpanded_explain",  title: "Step 5: NEW — Explainability", content: "Select any document to see which words drove its prediction, and flag lexicon disagreements."},
  {element: "#sidebarItemExpanded_confmatrix", title: "Step 6: NEW — Metrics", content: "Confusion matrix and F1 scores measure classifier accuracy against ground-truth labels."}
]
'

# ══════════════════════════════════════════════════════════════
#  SECTION 5 — UI
# ══════════════════════════════════════════════════════════════

ui <- dashboardPage(
  skin = "black", title = "SentimentIQ",
  
  dashboardHeader(
    title = tags$div(
      style = "display:flex;align-items:center;gap:10px;",
      tags$div(style="width:32px;height:32px;border-radius:8px;
               background:linear-gradient(135deg,#38bdf8,#6366f1);
               display:flex;align-items:center;justify-content:center;font-size:18px;color:#fff;",
               icon("brain")),
      tags$span("SentimentIQ",
                style="font-weight:800;font-size:17px;
                       background:linear-gradient(90deg,#38bdf8,#a78bfa);
                       -webkit-background-clip:text;-webkit-text-fill-color:transparent;")
    ), titleWidth=280),
  
  dashboardSidebar(width=260,
                   tags$style(HTML("
      .sidebar-menu li a{color:#94a3b8!important;font-size:13.5px}
      .sidebar-menu li.active>a{background:#0ea5e9!important;color:#fff!important;border-radius:8px}
      .sidebar-menu li a:hover{color:#fff!important;background:#0f2744!important}
      .main-sidebar{background:#050e1a!important}
    ")),
                   sidebarMenu(id="tabs",
                               menuItem("Home  Input",         tabName="home",       icon=icon("home")),
                               menuItem("Overview",            tabName="overview",   icon=icon("chart-pie")),
                               menuItem("Score Analysis",      tabName="scores",     icon=icon("chart-line")),
                               menuItem("Emotion Radar",       tabName="emotions",   icon=icon("heart")),
                               menuItem("Word Intelligence",   tabName="words",      icon=icon("font")),
                               menuItem("Bigrams N-grams",     tabName="ngrams",     icon=icon("link")),
                               # NEW TABS
                               menuItem("Explainability",      tabName="explain",    icon=icon("magnifying-glass")),
                               menuItem("Confusion Matrix",    tabName="confmatrix", icon=icon("table-cells")),
                               menuItem("Disagreement Flags",  tabName="disagree",   icon=icon("flag")),
                               menuItem("Raw Data Table",      tabName="table",      icon=icon("table")),
                               menuItem("Export  Samples",    tabName="export",     icon=icon("download")),
                               tags$hr(style="border-color:#1e3a5f;margin:12px 16px"),
                               # NEW: Shortcut hint + Tour button
                               tags$div(style="padding:8px 16px;",
                                        actionButton("start_tour", "Take a Tour", class="btn-default",
                                                     style="width:100%;margin-bottom:8px;"),
                                        tags$p(style="color:#475569;font-size:11px;margin:0;",
                                               "Press ? for keyboard shortcuts")
                               ),
                               tags$div(style="padding:4px 16px;color:#475569;font-size:11.5px;",
                                        "VIT 23MIS Team", tags$br(), "Rajat  Anshul  Kritika  Surya")
                   )
  ),
  
  dashboardBody(
    useShinyjs(),
    tags$head(
      tags$link(rel="stylesheet",
                href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"),
      
      tags$style(HTML("
      /* ── Base ── */
      body,.wrapper{background:#050e1a!important;color:#e2e8f0}
      .content-wrapper{background:#050e1a!important;padding:20px}
      .main-header .logo,.main-header .navbar{background:#050e1a!important;
        border-bottom:1px solid #1e3a5f!important}
      .box{background:#0d1b2a!important;border:1px solid #1e3a5f!important;
        border-radius:16px!important;box-shadow:0 4px 24px rgba(0,0,0,.4);color:#e2e8f0}
      .box-header{background:transparent!important;border-bottom:1px solid #1e3a5f}
      .box-title{color:#f1f5f9!important;font-weight:700;font-size:15px}
      label{color:#cbd5e1!important;font-weight:500}
      input,select,textarea{background:#050e1a!important;color:#f1f5f9!important;
        border:1px solid #334155!important;border-radius:8px!important}
      .btn-primary{background:linear-gradient(135deg,#0ea5e9,#6366f1)!important;
        border:none;border-radius:10px;font-weight:700;padding:10px 24px;
        font-size:14px;transition:transform .15s,box-shadow .15s}
      .btn-primary:hover{transform:translateY(-2px);
        box-shadow:0 8px 20px rgba(14,165,233,.35)!important}
      .btn-default{background:#0f2744!important;color:#94a3b8!important;
        border:1px solid #1e3a5f!important;border-radius:8px!important;
        font-size:12px!important;padding:6px 14px!important}
      .btn-default:hover{background:#1e3a5f!important;color:#fff!important}
      .value-box{border-radius:14px!important;border:none!important}
      .dataTables_wrapper{color:#cbd5e1!important}
      table.dataTable tbody tr{background:#0d1b2a!important;color:#e2e8f0}
      table.dataTable tbody tr:hover{background:#0f2744!important}
      table.dataTable thead{background:#050e1a;color:#38bdf8}
      .dataTables_filter input,.dataTables_length select{
        background:#050e1a!important;color:#e2e8f0!important;border:1px solid #334155!important}

      /* ── Shared utility classes ── */
      .insight-box{background:linear-gradient(135deg,#0f2744,#0d1b2a);
        border:1px solid #1e3a5f;border-left:4px solid #38bdf8;border-radius:10px;
        padding:14px 18px;margin-bottom:12px;font-size:13px;color:#cbd5e1;line-height:1.7}
      .ds-card{background:#0d1b2a;border:1px solid #1e3a5f;border-radius:12px;
        padding:14px 16px;margin-bottom:10px;height:100%}
      .ds-card:hover{border-color:#38bdf8}
      .domain-pill{display:inline-block;padding:2px 10px;border-radius:20px;
        font-size:11px;font-weight:700;margin-bottom:6px}
      .lexicon-badge{display:inline-block;padding:3px 10px;border-radius:20px;
        font-size:11px;font-weight:600;margin:2px}

      /* ── NEW: KPI Counter animation ── */
      @keyframes countUp {
        from { opacity:0; transform:translateY(8px); }
        to   { opacity:1; transform:translateY(0); }
      }
      .value-box .inner h3 {
        animation: countUp 0.6s ease both;
      }

      /* ── NEW: Progress bar ── */
      #progress-overlay{
        display:none;position:fixed;top:0;left:0;right:0;bottom:0;
        background:rgba(5,14,26,0.88);z-index:9999;
        display:flex;flex-direction:column;align-items:center;justify-content:center;
        backdrop-filter:blur(4px);
      }
      #progress-overlay.hidden{display:none!important;}
      .progress-card{
        background:#0d1b2a;border:1px solid #1e3a5f;border-radius:20px;
        padding:32px 48px;min-width:400px;text-align:center;
      }
      .progress-title{
        font-size:20px;font-weight:800;
        background:linear-gradient(90deg,#38bdf8,#a78bfa);
        -webkit-background-clip:text;-webkit-text-fill-color:transparent;
        margin-bottom:8px;
      }
      .progress-step{font-size:13px;color:#64748b;margin-bottom:18px;min-height:20px;}
      .progress-bar-outer{background:#1e3a5f;border-radius:8px;height:8px;overflow:hidden;}
      .progress-bar-inner{
        background:linear-gradient(90deg,#38bdf8,#6366f1);
        height:8px;border-radius:8px;width:0%;
        transition:width 0.4s ease;
      }
      .progress-pct{font-size:12px;color:#475569;margin-top:8px;}

      /* ── NEW: Tour overlay ── */
      #tour-overlay{
        display:none;position:fixed;top:0;left:0;right:0;bottom:0;
        background:rgba(5,14,26,0.7);z-index:8888;pointer-events:none;
      }
      #tour-overlay.active{display:block;}
      .tour-card{
        position:fixed;z-index:8889;pointer-events:all;
        background:#0d1b2a;border:1px solid #38bdf8;border-radius:16px;
        padding:20px 24px;max-width:340px;min-width:280px;
        box-shadow:0 0 40px rgba(56,189,248,0.2);
        animation:fadeInUp 0.25s ease;
      }
      @keyframes fadeInUp{
        from{opacity:0;transform:translateY(10px);}
        to{opacity:1;transform:translateY(0);}
      }
      .tour-card-title{font-size:14px;font-weight:700;color:#38bdf8;margin-bottom:8px;}
      .tour-card-content{font-size:13px;color:#94a3b8;line-height:1.6;margin-bottom:16px;}
      .tour-card-footer{display:flex;align-items:center;justify-content:space-between;}
      .tour-dots{display:flex;gap:6px;}
      .tour-dot{width:8px;height:8px;border-radius:50%;background:#1e3a5f;}
      .tour-dot.active{background:#38bdf8;}
      .tour-btn{background:#0ea5e9;color:#fff;border:none;border-radius:8px;
        padding:7px 16px;font-size:12px;font-weight:600;cursor:pointer;}
      .tour-skip{background:transparent;color:#475569;border:none;
        font-size:12px;cursor:pointer;padding:7px 10px;}

      /* ── NEW: Keyboard shortcuts modal ── */
      #shortcuts-modal{
        display:none;position:fixed;top:0;left:0;right:0;bottom:0;
        background:rgba(5,14,26,0.85);z-index:9998;
        align-items:center;justify-content:center;
      }
      #shortcuts-modal.active{display:flex!important;}
      .shortcuts-card{
        background:#0d1b2a;border:1px solid #1e3a5f;border-radius:20px;
        padding:28px 36px;min-width:380px;max-width:460px;
      }
      .shortcuts-title{font-size:17px;font-weight:700;color:#f1f5f9;margin-bottom:18px;
        display:flex;justify-content:space-between;align-items:center;}
      .shortcut-row{display:flex;justify-content:space-between;align-items:center;
        padding:8px 0;border-bottom:1px solid #1e3a5f;font-size:13px;}
      .shortcut-row:last-child{border-bottom:none;}
      .shortcut-key{background:#1e3a5f;color:#38bdf8;padding:3px 9px;border-radius:5px;
        font-family:monospace;font-size:12px;font-weight:700;}
      .shortcut-desc{color:#94a3b8;}

      /* ── NEW: Explainability panel ── */
      .explain-doc{
        background:#050e1a;border:1px solid #1e3a5f;border-radius:10px;
        padding:14px 16px;margin-bottom:12px;font-size:14px;line-height:1.8;
        color:#e2e8f0;
      }
      .explain-legend{display:flex;gap:16px;margin-bottom:12px;font-size:12px;color:#64748b;}
      .legend-pos{display:inline-block;background:#16412a;color:#4ade80;
        padding:2px 8px;border-radius:4px;font-weight:600;}
      .legend-neg{display:inline-block;background:#3f1212;color:#f87171;
        padding:2px 8px;border-radius:4px;font-weight:600;}

      /* ── NEW: Disagreement badges ── */
      .disagree-badge{display:inline-block;padding:2px 10px;border-radius:20px;
        font-size:11px;font-weight:700;}
      .badge-unanimous{background:#14532d22;color:#22c55e;border:1px solid #14532d;}
      .badge-slight{background:#78350f22;color:#f59e0b;border:1px solid #78350f;}
      .badge-moderate{background:#7c2d1222;color:#f97316;border:1px solid #7c2d12;}
      .badge-strong{background:#450a0a22;color:#ef4444;border:1px solid #450a0a;}
      .negation-flag{background:#4c1d9522;color:#a78bfa;border:1px solid #4c1d95;
        display:inline-block;padding:2px 8px;border-radius:4px;font-size:11px;}

      /* ── NEW: Metric cards (F1) ── */
      .metric-card{background:#050e1a;border:1px solid #1e3a5f;border-radius:12px;
        padding:16px;text-align:center;}
      .metric-val{font-size:28px;font-weight:800;
        background:linear-gradient(135deg,#38bdf8,#6366f1);
        -webkit-background-clip:text;-webkit-text-fill-color:transparent;}
      .metric-label{font-size:11px;color:#475569;margin-top:4px;}
      .metric-sub{font-size:12px;color:#64748b;margin-top:6px;}
    ")),
      
      # ── Keyboard shortcuts modal ─────────────────────────────
      tags$div(id="shortcuts-modal",
               tags$div(class="shortcuts-card",
                        tags$div(class="shortcuts-title",
                                 "Keyboard shortcuts",
                                 tags$span(id="close-shortcuts", style="cursor:pointer;color:#64748b;font-size:20px;", HTML("&times;"))
                        ),
                        tags$div(class="shortcut-row",
                                 tags$span(class="shortcut-key", "?"),
                                 tags$span(class="shortcut-desc", "Show / hide this panel")
                        ),
                        tags$div(class="shortcut-row",
                                 tags$span(class="shortcut-key", "R"),
                                 tags$span(class="shortcut-desc", "Run analysis")
                        ),
                        tags$div(class="shortcut-row",
                                 tags$span(class="shortcut-key", "1–9"),
                                 tags$span(class="shortcut-desc", "Navigate to tab by number")
                        ),
                        tags$div(class="shortcut-row",
                                 tags$span(class="shortcut-key", "T"),
                                 tags$span(class="shortcut-desc", "Start guided tour")
                        ),
                        tags$div(class="shortcut-row",
                                 tags$span(class="shortcut-key", "Esc"),
                                 tags$span(class="shortcut-desc", "Close modals / cancel tour")
                        ),
                        tags$div(class="shortcut-row",
                                 tags$span(class="shortcut-key", "H"),
                                 tags$span(class="shortcut-desc", "Go to Home tab")
                        )
               )
      ),
      
      # ── Progress bar overlay ──────────────────────────────────
      tags$div(id="progress-overlay", class="hidden",
               tags$div(class="progress-card",
                        tags$div(class="progress-title", icon("brain"), " SentimentIQ"),
                        tags$div(id="progress-step-label", class="progress-step", "Initialising..."),
                        tags$div(class="progress-bar-outer",
                                 tags$div(id="progress-bar-inner", class="progress-bar-inner")
                        ),
                        tags$div(id="progress-pct", class="progress-pct", "0%")
               )
      ),
      
      # ── Tour overlay (populated by JS) ──────────────────────
      tags$div(id="tour-overlay"),
      
      # ── Keyboard + Tour JS ───────────────────────────────────
      tags$script(HTML(sprintf('
      // ── Keyboard shortcuts ───────────────────────────────
      var TAB_NAMES = ["home","overview","scores","emotions","words","ngrams","explain","confmatrix","disagree","table","export"];
      document.addEventListener("keydown", function(e) {
        var tag = document.activeElement.tagName.toLowerCase();
        if (tag === "input" || tag === "textarea" || tag === "select") return;
        var k = e.key.toUpperCase();
        if (k === "?") {
          var m = document.getElementById("shortcuts-modal");
          m.classList.toggle("active");
        }
        if (k === "ESCAPE") {
          document.getElementById("shortcuts-modal").classList.remove("active");
          endTour();
        }
        if (k === "T") { startTour(); }
        if (k === "H") { Shiny.setInputValue("kb_tab", "home", {priority: "event"}); }
        if (k === "R") { document.getElementById("analyze").click(); }
        var num = parseInt(e.key);
        if (!isNaN(num) && num >= 1 && num <= TAB_NAMES.length) {
          Shiny.setInputValue("kb_tab", TAB_NAMES[num-1], {priority: "event"});
        }
      });
      document.getElementById("close-shortcuts").addEventListener("click", function(){
        document.getElementById("shortcuts-modal").classList.remove("active");
      });

      // ── Tour logic ────────────────────────────────────────
      var tourSteps = %s;
      var tourIndex = 0;
      var tourCard  = null;

      function startTour() {
        tourIndex = 0;
        document.getElementById("tour-overlay").classList.add("active");
        showTourStep();
      }

      function endTour() {
        document.getElementById("tour-overlay").classList.remove("active");
        if (tourCard && tourCard.parentNode) tourCard.parentNode.removeChild(tourCard);
        tourCard = null;
      }

      function showTourStep() {
        if (tourCard && tourCard.parentNode) tourCard.parentNode.removeChild(tourCard);
        if (tourIndex >= tourSteps.length) { endTour(); return; }
        var step = tourSteps[tourIndex];

        // Build card
        tourCard = document.createElement("div");
        tourCard.className = "tour-card";

        var dotsHTML = tourSteps.map(function(_,i){
          return "<div class=\'tour-dot" + (i===tourIndex?" active":"") + "\'></div>";
        }).join("");

        tourCard.innerHTML =
          "<div class=\'tour-card-title\'>" + step.title + "</div>" +
          "<div class=\'tour-card-content\'>" + step.content + "</div>" +
          "<div class=\'tour-card-footer\'>" +
            "<div class=\'tour-dots\'>" + dotsHTML + "</div>" +
            "<div style=\'display:flex;gap:6px;\'>" +
              "<button class=\'tour-skip\' onclick=\'endTour()\'>Skip</button>" +
              "<button class=\'tour-btn\' onclick=\'tourNext()\'>" +
                (tourIndex < tourSteps.length - 1 ? "Next →" : "Finish") +
              "</button>" +
            "</div>" +
          "</div>";

        // Position near target element
        var el = document.querySelector(step.element);
        var rect = el ? el.getBoundingClientRect() : {top:100, left:200, bottom:100, right:200};
        var top  = Math.min(rect.bottom + 12, window.innerHeight - 220);
        var left = Math.max(Math.min(rect.left, window.innerWidth - 360), 16);
        tourCard.style.top  = top  + "px";
        tourCard.style.left = left + "px";

        document.body.appendChild(tourCard);
      }

      function tourNext() {
        tourIndex++;
        showTourStep();
      }

      // Expose to button in sidebar
      document.addEventListener("DOMContentLoaded", function(){
        var btn = document.getElementById("start_tour");
        if (btn) btn.addEventListener("click", startTour);
      });

      // ── Progress bar helpers ──────────────────────────────
      var STEPS = %s;
      function showProgress() {
        document.getElementById("progress-overlay").classList.remove("hidden");
        var bar   = document.getElementById("progress-bar-inner");
        var label = document.getElementById("progress-step-label");
        var pct   = document.getElementById("progress-pct");
        var idx   = 0;
        var total = STEPS.length;
        bar.style.width = "0%%";

        function tick() {
          if (idx >= total) {
            bar.style.width = "100%%";
            pct.textContent = "100%%";
            setTimeout(function(){ hideProgress(); }, 400);
            return;
          }
          label.textContent = STEPS[idx];
          var p = Math.round(((idx+1)/total)*100);
          bar.style.width = p + "%%";
          pct.textContent = p + "%%";
          idx++;
          setTimeout(tick, 320);
        }
        tick();
      }
      function hideProgress() {
        document.getElementById("progress-overlay").classList.add("hidden");
      }

      // Intercept analyze click
      $(document).on("click", "#analyze", function(){
        showProgress();
      });
    ', TOUR_STEPS_JS, jsonlite::toJSON(PIPELINE_STEPS))))
    ),
    
    tabItems(
      
      # ── HOME ──────────────────────────────────────────────
      tabItem(tabName="home",
              fluidRow(
                box(width=12, title="Select Dataset and Run Analysis",
                    fluidRow(
                      column(4,
                             selectInput("source","Data Source",choices=c(
                               "Built-in: IMDB Movie Reviews"           = "imdb",
                               "Built-in: Twitter / X Posts"            = "twitter",
                               "Built-in: Amazon Product Reviews"       = "amazon",
                               "Built-in: Reddit Mental Health Posts"   = "reddit",
                               "Built-in: News Article Headlines"       = "news",
                               "Built-in: Customer Support Tickets"     = "support",
                               "Custom: Paste Text"                     = "manual",
                               "Custom: Upload CSV"                     = "csv"
                             )),
                             conditionalPanel("input.source == 'manual'",
                                              textAreaInput("text","One sentence per line:",rows=7,
                                                            placeholder="The film was absolutely brilliant!\nTerrible acting and a weak plot.\nDecent overall.")
                             ),
                             conditionalPanel("input.source == 'csv'",
                                              fileInput("file","Upload CSV"),
                                              p("Col 1 = text, Col 2 (optional) = label",style="color:#64748b;font-size:11.5px;")
                             ),
                             br(),
                             actionButton("analyze","Run Full Analysis",class="btn-primary"),
                             hidden(div(id="loading",br(),
                                        p("Running NLP pipeline...",style="color:#38bdf8;font-size:13px;")))
                      ),
                      column(8, uiOutput("ds_info"))
                    )
                )
              ),
              fluidRow(
                box(width=12, title="Dataset Library",
                    fluidRow(
                      lapply(names(DATASETS), function(k) {
                        ds  <- DATASETS[[k]]
                        col <- DOMAIN_COLS[[ds$domain]]
                        column(2,
                               tags$div(class="ds-card",
                                        tags$span(ds$domain,class="domain-pill",
                                                  style=paste0("background:",col,"22;color:",col,";")),
                                        tags$br(),
                                        tags$b(ds$label,style="font-size:12px;color:#f1f5f9;"), tags$br(),
                                        tags$span(paste0(ds$n," texts"),style="font-size:11px;color:#64748b;"),
                                        tags$br(),tags$br(),
                                        tags$p(ds$desc,style="font-size:11px;color:#64748b;line-height:1.5;"),
                                        actionButton(paste0("load_",k),"Load",
                                                     class="btn-default",style="width:100%;")
                               )
                        )
                      })
                    )
                )
              )
      ),
      
      # ── OVERVIEW ─────────────────────────────────────────
      tabItem(tabName="overview",
              fluidRow(
                valueBoxOutput("vb_pos",width=4), valueBoxOutput("vb_neg",width=4),
                valueBoxOutput("vb_neu",width=4)
              ),
              fluidRow(
                valueBoxOutput("vb_total",width=3), valueBoxOutput("vb_avg",width=3),
                valueBoxOutput("vb_pct",width=3),   valueBoxOutput("vb_acc",width=3)
              ),
              fluidRow(
                box(width=8,title="Score Distribution Across All Four Lexicons",
                    plotOutput("ov_bar",height=320)),
                box(width=4,title="Auto-generated Insights",uiOutput("insights"))
              ),
              fluidRow(
                box(width=6,title="Syuzhet Score Density by Class",
                    plotOutput("ov_density",height=280)),
                box(width=6,title="AFINN vs NRC Correlation",
                    plotOutput("ov_scatter",height=280))
              )
      ),
      
      # ── SCORES ───────────────────────────────────────────
      tabItem(tabName="scores",
              fluidRow(box(width=12,title="Ridgeline: All Four Lexicons",
                           plotOutput("sc_ridge",height=360))),
              fluidRow(
                box(width=6,title="Syuzhet Trend (LOESS)",plotOutput("sc_trend",height=280)),
                box(width=6,title="Score by Sentiment Class",plotOutput("sc_box",height=280))
              ),
              fluidRow(box(width=12,title="Inter-Lexicon Agreement Heatmap",
                           plotOutput("sc_heatmap",height=320)))
      ),
      
      # ── EMOTIONS ─────────────────────────────────────────
      tabItem(tabName="emotions",
              fluidRow(
                box(width=8,title="NRC 8-Emotion Average Scores",plotOutput("em_bar",height=350)),
                box(width=4,title="Emotion Summary",uiOutput("em_stats"))
              ),
              fluidRow(
                box(width=6,title="Emotion Heatmap by Sentiment Class",plotOutput("em_heat",height=300)),
                box(width=6,title="Emotion Correlation Matrix",plotOutput("em_cor",height=300))
              )
      ),
      
      # ── WORDS ────────────────────────────────────────────
      tabItem(tabName="words",
              fluidRow(
                box(width=6,title="Top Bing Sentiment Words",plotOutput("wd_bing",height=360)),
                box(width=6,title="Top 20 Content Words",plotOutput("wd_freq",height=360))
              ),
              fluidRow(box(width=12,title="Word Cloud",wordcloud2Output("wcloud",height="400px")))
      ),
      
      # ── NGRAMS ───────────────────────────────────────────
      tabItem(tabName="ngrams",
              fluidRow(
                box(width=7,title="Top 20 Bigrams",plotOutput("bi_bar",height=380)),
                box(width=5,title="Bigram Notes",
                    div(class="insight-box",
                        tags$b("Why bigrams matter:"), tags$br(),
                        "Unigram analysis misses context. Bigrams surface patterns like",
                        " 'not good', 'really love', 'highly recommend'.", tags$br(), tags$br(),
                        "Both word positions are cleared of stopwords before counting."
                    ),
                    uiOutput("bi_stats")
                )
              ),
              fluidRow(box(width=12,title="AFINN Word Contributions",
                           plotOutput("bi_afinn",height=320)))
      ),
      
      # ══════════════════════════════════════════════════════
      # NEW TAB 1 — EXPLAINABILITY
      # ══════════════════════════════════════════════════════
      tabItem(tabName="explain",
              fluidRow(
                box(width=12, title="Per-Document Explainability",
                    fluidRow(
                      column(4,
                             selectInput("explain_doc", "Select document:", choices=NULL),
                             uiOutput("explain_meta")
                      ),
                      column(8,
                             div(class="explain-legend",
                                 tags$span(class="legend-pos", "positive word"),
                                 tags$span(class="legend-neg", "negative word"),
                                 tags$span(style="color:#64748b;font-size:11px;", " (Bing lexicon highlights)")
                             ),
                             div(class="explain-doc", uiOutput("explain_highlighted"))
                      )
                    )
                )
              ),
              fluidRow(
                box(width=8, title="LIME-style Word Importance for Selected Document",
                    plotOutput("explain_lime", height=320)),
                box(width=4, title="Lexicon Scores",
                    uiOutput("explain_scores"))
              )
      ),
      
      # ══════════════════════════════════════════════════════
      # NEW TAB 2 — CONFUSION MATRIX + METRICS
      # ══════════════════════════════════════════════════════
      tabItem(tabName="confmatrix",
              fluidRow(
                box(width=7, title="Confusion Matrix (Predicted vs Ground Truth)",
                    uiOutput("conf_placeholder"),
                    plotOutput("conf_matrix", height=380)
                ),
                box(width=5, title="Per-Class Precision / Recall / F1",
                    uiOutput("metrics_table")
                )
              ),
              fluidRow(
                box(width=12, title="What these metrics mean",
                    div(class="insight-box",
                        tags$b("Precision"), " — of all documents predicted as class X, what fraction truly belong to X?", tags$br(),
                        tags$b("Recall"), " — of all true X documents, what fraction did the model correctly identify?", tags$br(),
                        tags$b("F1 Score"), " — harmonic mean of precision and recall. Best single metric for imbalanced classes.", tags$br(), tags$br(),
                        "The predicted label here is the Syuzhet score polarity. Ground-truth labels come from the built-in dataset annotations."
                    )
                )
              )
      ),
      
      # ══════════════════════════════════════════════════════
      # NEW TAB 3 — DISAGREEMENT FLAGS
      # ══════════════════════════════════════════════════════
      tabItem(tabName="disagree",
              fluidRow(
                box(width=4, title="Disagreement Summary",
                    uiOutput("disagree_summary")
                ),
                box(width=8, title="Disagreement Distribution",
                    plotOutput("disagree_bar", height=280))
              ),
              fluidRow(
                box(width=12, title="Documents with Lexicon Disagreement",
                    uiOutput("disagree_top"),
                    DTOutput("disagree_table")
                )
              ),
              fluidRow(
                box(width=12, title="Negation Pattern Flags",
                    div(class="insight-box",
                        icon("circle-info"), " ",
                        "These documents contain phrases where a negation word immediately precedes a sentiment word (e.g. 'not good', 'never satisfied'). Lexicon-based methods often miss these and may mis-classify the document."
                    ),
                    DTOutput("negation_table")
                )
              )
      ),
      
      # ── TABLE ────────────────────────────────────────────
      tabItem(tabName="table",
              box(width=12,title="Full Results Table",DTOutput("raw_table"))
      ),
      
      # ── EXPORT ───────────────────────────────────────────
      tabItem(tabName="export",
              fluidRow(
                box(width=6,title="Download Analysis Results",
                    p("Download scored output from the current run.",style="color:#94a3b8;font-size:13px;"), br(),
                    downloadButton("dl_res",    "Full Results CSV",      class="btn-primary"), br(),br(),
                    downloadButton("dl_tokens", "Token-level Data CSV",  class="btn-primary"), br(),br(),
                    downloadButton("dl_bigrams","Bigrams CSV",           class="btn-primary"), br(),br(),
                    downloadButton("dl_flags",  "Disagreement Flags CSV",class="btn-primary")
                ),
                box(width=6,title="Download Sample Datasets (CSV)",
                    p("Pre-built CSV files for external use or re-upload.",style="color:#94a3b8;font-size:13px;"), br(),
                    downloadButton("dl_s_imdb",   "IMDB Movie Reviews",         class="btn-default"), br(),br(),
                    downloadButton("dl_s_twitter","Twitter / X Posts",          class="btn-default"), br(),br(),
                    downloadButton("dl_s_amazon", "Amazon Product Reviews",     class="btn-default"), br(),br(),
                    downloadButton("dl_s_reddit", "Reddit Mental Health Posts", class="btn-default"), br(),br(),
                    downloadButton("dl_s_news",   "News Headlines",             class="btn-default"), br(),br(),
                    downloadButton("dl_s_support","Customer Support Tickets",   class="btn-default")
                )
              )
      )
    )
  )
)

# ══════════════════════════════════════════════════════════════
#  SECTION 6 — SERVER
# ══════════════════════════════════════════════════════════════

server <- function(input, output, session) {
  
  # ── Keyboard shortcut tab navigation ─────────────────────
  observeEvent(input$kb_tab, {
    updateTabItems(session, "tabs", input$kb_tab)
  })
  
  # ── Quick-load gallery buttons ───────────────────────────
  for (k in names(DATASETS)) {
    local({
      key <- k
      observeEvent(input[[paste0("load_", key)]], {
        updateSelectInput(session, "source", selected = key)
      })
    })
  }
  
  # ── Dataset info panel ───────────────────────────────────
  output$ds_info <- renderUI({
    src <- input$source
    if (!src %in% names(DATASETS)) {
      return(div(class="insight-box",
                 tags$b("Custom Input Mode"), tags$br(),
                 "Paste text (one sentence per line) or upload a CSV.",
                 " First column = text, optional second = label."
      ))
    }
    ds  <- DATASETS[[src]]
    col <- DOMAIN_COLS[[ds$domain]]
    div(
      div(class="insight-box",
          tags$span(ds$domain, class="domain-pill",
                    style=paste0("background:",col,"22;color:",col,";")),
          tags$br(), tags$b(ds$label), tags$br(), tags$br(),
          ds$desc, tags$br(), tags$br(),
          tags$b("Documents: "), ds$n, tags$b("  |  Domain: "), ds$domain
      ),
      div(class="insight-box",
          tags$b("Lexicons applied: "),
          tags$span("AFINN",   class="lexicon-badge",style="background:#1e3a5f;color:#38bdf8;"),
          tags$span("Bing",    class="lexicon-badge",style="background:#14532d;color:#22c55e;"),
          tags$span("NRC",     class="lexicon-badge",style="background:#4c1d95;color:#a78bfa;"),
          tags$span("Syuzhet", class="lexicon-badge",style="background:#7c2d12;color:#fb923c;"),
          tags$br(), tags$br(),
          tags$b("NLP steps: "), "tokenisation  stopword removal  multi-lexicon scoring  NRC emotion detection  bigram extraction  negation detection  disagreement flagging"
      )
    )
  })
  
  # ── Core analysis reactive ────────────────────────────────
  results <- eventReactive(input$analyze, {
    shinyjs::disable("analyze"); shinyjs::show("loading")
    src <- input$source; texts <- character(0); labels <- NULL
    
    if (src %in% names(DATASETS)) {
      ds <- DATASETS[[src]]; texts <- ds$data$text; labels <- ds$data$label
    } else if (src == "manual") {
      req(input$text)
      texts <- trimws(unlist(strsplit(input$text,"\n"))); texts <- texts[nchar(texts)>0]
    } else {
      req(input$file)
      raw <- read.csv(input$file$datapath, stringsAsFactors=FALSE)
      texts <- as.character(raw[[1]])
      if (ncol(raw)>=2) labels <- as.character(raw[[2]])
    }
    validate(need(length(texts)>=3,"Please provide at least 3 text samples."))
    res <- run_analysis(texts, labels)
    shinyjs::hide("loading"); shinyjs::enable("analyze")
    
    # Update explainability document selector
    doc_choices <- setNames(seq_along(texts), paste0("[", seq_along(texts), "] ", substr(texts, 1, 60)))
    updateSelectInput(session, "explain_doc", choices=doc_choices)
    
    updateTabItems(session,"tabs","overview")
    res
  })
  
  # ── Value boxes ───────────────────────────────────────────
  output$vb_pos   <- renderValueBox(valueBox(sum(results()$df$predicted=="Positive"),"Positive",icon("thumbs-up"),color="green"))
  output$vb_neg   <- renderValueBox(valueBox(sum(results()$df$predicted=="Negative"),"Negative",icon("thumbs-down"),color="red"))
  output$vb_neu   <- renderValueBox(valueBox(sum(results()$df$predicted=="Neutral"), "Neutral", icon("circle"),color="yellow"))
  output$vb_total <- renderValueBox(valueBox(nrow(results()$df),"Total Documents",icon("file-lines"),color="blue"))
  output$vb_avg   <- renderValueBox(valueBox(round(mean(results()$df$score_syuzhet),3),"Mean Syuzhet Score",icon("scale-balanced"),color="purple"))
  output$vb_pct   <- renderValueBox(valueBox(paste0(round(mean(results()$df$predicted=="Positive")*100,1),"%"),"Positive Rate",icon("percent"),color="teal"))
  output$vb_acc   <- renderValueBox({
    df <- results()$df
    if (!"label"%in%names(df)) valueBox("N/A","Accuracy (no labels)",icon("bullseye"),color="navy")
    else valueBox(paste0(round(mean(df$predicted==df$label,na.rm=TRUE)*100,1),"%"),"Label Accuracy",icon("bullseye"),color="navy")
  })
  
  # ── Insights ─────────────────────────────────────────────
  output$insights <- renderUI({
    df       <- results()$df; wf <- results()$word_freq
    dom      <- names(sort(table(df$predicted),decreasing=TRUE))[1]
    pos_rate <- round(mean(df$predicted=="Positive")*100)
    avg_sc   <- round(mean(df$score_syuzhet),2)
    afinn_sd <- round(sd(df$score_afinn),2)
    top_w    <- if(nrow(wf)>0) wf$word[1] else "N/A"
    n_disagree <- sum(df$disagreement_flag, na.rm=TRUE)
    n_negation <- sum(!is.na(df$negation_found))
    tags$div(
      div(class="insight-box",sprintf("Dominant sentiment: %s — %d%% positive documents.",dom,pos_rate)),
      div(class="insight-box",sprintf("Mean Syuzhet score: %.2f (positive = net-positive corpus).",avg_sc)),
      div(class="insight-box",sprintf("AFINN std-dev: %.2f — %s polarisation.",afinn_sd,ifelse(afinn_sd>2,"high","moderate"))),
      div(class="insight-box",sprintf("Most frequent content word: \"%s\".",top_w)),
      div(class="insight-box",sprintf("⚠ %d documents show lexicon disagreement; %d contain negation patterns.", n_disagree, n_negation))
    )
  })
  
  # ── Overview plots ────────────────────────────────────────
  output$ov_bar <- renderPlot({
    df <- results()$df %>%
      select(score_afinn,score_bing,score_nrc,score_syuzhet,predicted) %>%
      pivot_longer(starts_with("score_"),names_to="lexicon",values_to="score") %>%
      mutate(lexicon=toupper(str_remove(lexicon,"score_")))
    ggplot(df,aes(x=score,fill=predicted))+geom_histogram(bins=25,alpha=.85,color="transparent")+
      facet_wrap(~lexicon,scales="free_x",nrow=1)+scale_fill_manual(values=SENT_COLORS)+
      labs(x="Score",y="Count",fill="Predicted",title="Score distribution across four lexicons")+theme_dark_vit()
  })
  output$ov_density <- renderPlot({
    ggplot(results()$df,aes(x=score_syuzhet,fill=predicted))+
      geom_density(alpha=.7,color="transparent")+scale_fill_manual(values=SENT_COLORS)+
      labs(x="Syuzhet Score",y="Density",fill="Predicted",title="Syuzhet score density by class")+theme_dark_vit()
  })
  output$ov_scatter <- renderPlot({
    ggplot(results()$df,aes(x=score_afinn,y=score_nrc,color=predicted))+
      geom_point(alpha=.65,size=2.5)+geom_smooth(method="lm",se=FALSE,linewidth=1,color="#38bdf8")+
      scale_color_manual(values=SENT_COLORS)+
      labs(x="AFINN Score",y="NRC Score",color="Predicted",title="AFINN vs NRC inter-lexicon agreement")+theme_dark_vit()
  })
  
  # ── Score analysis plots ──────────────────────────────────
  output$sc_ridge <- renderPlot({
    df <- results()$df %>%
      select(predicted,score_afinn,score_bing,score_nrc,score_syuzhet) %>%
      pivot_longer(-predicted,names_to="lexicon",values_to="score") %>%
      mutate(lexicon=toupper(str_remove(lexicon,"score_")))
    ggplot(df,aes(x=score,y=lexicon,fill=stat(x)))+
      geom_density_ridges_gradient(scale=1.8,rel_min_height=0.01,color="#1e3a5f")+
      scale_fill_gradient2(low="#ef4444",mid="#94a3b8",high="#22c55e",midpoint=0)+
      labs(x="Score",y=NULL,title="Ridgeline: score distribution across all four lexicons")+
      theme_dark_vit()+theme(legend.position="none")
  })
  output$sc_trend <- renderPlot({
    df <- results()$df %>% mutate(idx=row_number())
    df$smooth <- predict(loess(score_syuzhet~idx,data=df,span=.25))
    ggplot(df,aes(idx))+
      geom_line(aes(y=score_syuzhet),color="#334155",linewidth=.6)+
      geom_line(aes(y=smooth),color="#38bdf8",linewidth=1.4)+
      geom_hline(yintercept=0,color="#f59e0b",linetype="dashed")+
      labs(x="Document Index",y="Syuzhet Score",title="Sentiment trend — LOESS smoothed")+theme_dark_vit()
  })
  output$sc_box <- renderPlot({
    ggplot(results()$df,aes(predicted,score_syuzhet,fill=predicted))+
      geom_boxplot(alpha=.8,outlier.color="#94a3b8")+scale_fill_manual(values=SENT_COLORS)+
      labs(x=NULL,y="Syuzhet Score",title="Score distribution by sentiment class")+
      theme_dark_vit()+theme(legend.position="none")
  })
  output$sc_heatmap <- renderPlot({
    df <- results()$df %>%
      select(id,score_afinn,score_bing,score_nrc,score_syuzhet) %>%
      mutate(across(-id,~ifelse(.>0,"Positive",ifelse(.<0,"Negative","Neutral"))))
    nms  <- c("AFINN","BING","NRC","SYUZHET")
    cols <- c("score_afinn","score_bing","score_nrc","score_syuzhet")
    am   <- outer(seq_along(cols),seq_along(cols),Vectorize(function(i,j)
      round(mean(df[[cols[i]]]==df[[cols[j]]])*100,1)))
    dimnames(am) <- list(nms,nms)
    mat_df <- as.data.frame(am) %>% mutate(L1=rownames(.)) %>%
      pivot_longer(-L1,names_to="L2",values_to="Agreement")
    ggplot(mat_df,aes(L1,L2,fill=Agreement))+geom_tile(color="#050e1a",linewidth=.8)+
      geom_text(aes(label=paste0(Agreement,"%")),color="white",fontface="bold")+
      scale_fill_gradient(low="#1e3a5f",high="#0ea5e9")+
      labs(title="Inter-lexicon agreement (%)",x=NULL,y=NULL)+
      theme_dark_vit()+coord_fixed()
  })
  
  # ── Emotion plots ─────────────────────────────────────────
  EMOT <- c("anger","anticipation","disgust","fear","joy","sadness","surprise","trust")
  
  output$em_bar <- renderPlot({
    avg <- colMeans(results()$df[,EMOT])
    edf <- tibble(emotion=names(avg),score=avg) %>% arrange(desc(score)) %>% mutate(emotion=fct_inorder(emotion))
    ggplot(edf,aes(emotion,score,fill=emotion))+geom_col(alpha=.9)+
      geom_text(aes(label=round(score,3)),vjust=-0.4,color="#cbd5e1",size=3.8)+
      scale_fill_manual(values=EMOTION_COLS)+
      labs(x=NULL,y="Mean NRC Score",title="NRC Emotion Lexicon — average scores across corpus",
           subtitle="NRC Word-Emotion Association Lexicon (Mohammad & Turney 2013)")+
      theme_dark_vit()+theme(legend.position="none")
  })
  output$em_stats <- renderUI({
    avg <- colMeans(results()$df[,EMOT])
    top <- names(sort(avg,decreasing=TRUE))[1:3]; bot <- names(sort(avg))[1:3]
    tags$div(
      div(class="insight-box",tags$b("Top 3 emotions:"),tags$br(),paste(paste0(1:3,". ",top),collapse="  ")),
      div(class="insight-box",tags$b("Least present:"),tags$br(),paste(paste0(1:3,". ",bot),collapse="  ")),
      div(class="insight-box",tags$b("Joy / Sadness ratio: "),round(avg["joy"]/max(avg["sadness"],.001),2))
    )
  })
  output$em_heat <- renderPlot({
    df <- results()$df %>% group_by(predicted) %>%
      summarise(across(all_of(EMOT),mean)) %>%
      pivot_longer(-predicted,names_to="emotion",values_to="score")
    ggplot(df,aes(emotion,predicted,fill=score))+geom_tile(color="#050e1a",linewidth=.8)+
      geom_text(aes(label=round(score,2)),color="white",fontface="bold",size=3.5)+
      scale_fill_gradient(low="#1e3a5f",high="#6366f1")+
      labs(title="Mean emotion scores per sentiment class",x=NULL,y=NULL)+
      theme_dark_vit()+theme(axis.text.x=element_text(angle=30,hjust=1))
  })
  output$em_cor <- renderPlot({
    cm     <- round(cor(results()$df[,EMOT]),2)
    cm_lng <- as.data.frame(as.table(cm)) %>% rename(e1=Var1,e2=Var2,corr=Freq)
    ggplot(cm_lng,aes(e1,e2,fill=corr))+geom_tile(color="#050e1a",linewidth=.6)+
      geom_text(aes(label=corr),color="white",size=3.2)+
      scale_fill_gradient2(low="#ef4444",mid="#0d1b2a",high="#22c55e",midpoint=0,limits=c(-1,1))+
      labs(title="Emotion correlation matrix",x=NULL,y=NULL,fill="r")+
      theme_dark_vit()+coord_fixed()+theme(axis.text.x=element_text(angle=35,hjust=1))
  })
  
  # ── Word plots ────────────────────────────────────────────
  output$wd_bing <- renderPlot({
    tw <- results()$bing_words %>% count(word,sentiment,sort=TRUE) %>%
      group_by(sentiment) %>% slice_max(n,n=15) %>% ungroup() %>%
      mutate(word=reorder_within(word,n,sentiment),n=ifelse(sentiment=="negative",-n,n))
    ggplot(tw,aes(word,n,fill=sentiment))+geom_col(show.legend=FALSE,alpha=.85)+
      scale_fill_manual(values=c(positive="#22c55e",negative="#ef4444"))+
      scale_x_reordered()+coord_flip()+facet_wrap(~sentiment,scales="free")+
      labs(x=NULL,y="Frequency",title="Most frequent sentiment words (Bing lexicon)")+theme_dark_vit()
  })
  output$wd_freq <- renderPlot({
    t20 <- head(results()$word_freq,20) %>% mutate(word=fct_reorder(word,n))
    ggplot(t20,aes(word,n,fill=n))+geom_col(show.legend=FALSE,alpha=.85)+
      geom_text(aes(label=n),hjust=-0.2,color="#cbd5e1",size=3.2)+
      scale_fill_gradient(low="#1e3a5f",high="#38bdf8")+coord_flip()+
      expand_limits(y=max(t20$n)*1.15)+
      labs(x=NULL,y="Count",title="Top 20 content words")+theme_dark_vit()
  })
  output$wcloud <- renderWordcloud2({
    wf <- results()$word_freq %>% filter(n>=2) %>% head(150)
    wordcloud2(wf,color="random-light",backgroundColor="#050e1a",fontFamily="Segoe UI",size=.55)
  })
  
  # ── Bigram plots ──────────────────────────────────────────
  output$bi_bar <- renderPlot({
    bg <- head(results()$bigrams,20) %>% mutate(bigram=fct_reorder(bigram,n))
    ggplot(bg,aes(bigram,n,fill=n))+geom_col(show.legend=FALSE,alpha=.85)+
      geom_text(aes(label=n),hjust=-0.2,color="#cbd5e1",size=3.2)+
      scale_fill_gradient(low="#1e3a5f",high="#a78bfa")+coord_flip()+
      expand_limits(y=max(bg$n)*1.15)+
      labs(x=NULL,y="Count",title="Top 20 bigrams")+theme_dark_vit()
  })
  output$bi_stats <- renderUI({
    bg <- results()$bigrams
    tags$div(
      div(class="insight-box",tags$b("Unique bigrams found: "),nrow(bg)),
      div(class="insight-box",tags$b("Top bigram: "),paste0('"',bg$bigram[1],'"  (',bg$n[1],' occurrences)'))
    )
  })
  output$bi_afinn <- renderPlot({
    contrib <- results()$afinn_words %>% count(word,value) %>%
      mutate(contribution=n*value) %>% arrange(desc(abs(contribution))) %>% head(30) %>%
      mutate(word=fct_reorder(word,contribution),
             sentiment=ifelse(contribution>0,"Positive","Negative"))
    ggplot(contrib,aes(word,contribution,fill=sentiment))+
      geom_col(show.legend=FALSE,alpha=.85)+
      scale_fill_manual(values=c(Positive="#22c55e",Negative="#ef4444"))+coord_flip()+
      labs(x=NULL,y="Contribution (frequency x AFINN score)",
           title="Top contributing words — AFINN lexicon",
           subtitle="Most impactful words driving corpus-wide sentiment score")+theme_dark_vit()
  })
  
  # ══════════════════════════════════════════════════════════
  # NEW: EXPLAINABILITY SERVER LOGIC
  # ══════════════════════════════════════════════════════════
  
  output$explain_meta <- renderUI({
    req(results(), input$explain_doc)
    doc_id <- as.integer(input$explain_doc)
    row    <- results()$df[doc_id, ]
    
    sent_col <- switch(row$predicted,
                       "Positive" = "#22c55e",
                       "Negative" = "#ef4444",
                       "#f59e0b"
    )
    
    disagree_class <- switch(row$disagreement_label,
                             "Unanimous" = "badge-unanimous",
                             "Slight"    = "badge-slight",
                             "Moderate"  = "badge-moderate",
                             "Strong"    = "badge-strong",
                             "badge-slight"
    )
    
    tags$div(
      div(class="insight-box",
          tags$b("Document ID: "), doc_id, tags$br(),
          tags$b("Predicted: "),
          tags$span(row$predicted, style=paste0("color:",sent_col,";font-weight:700;")),
          tags$br(),
          if ("label" %in% names(row)) {
            tags$span(tags$b("True label: "), row$label, tags$br())
          },
          tags$b("Syuzhet score: "), round(row$score_syuzhet, 3), tags$br(),
          tags$b("AFINN score: "), round(row$score_afinn, 3), tags$br(),
          tags$br(),
          tags$b("Lexicon agreement: "),
          tags$span(class=paste("disagree-badge", disagree_class), row$disagreement_label),
          tags$br(), tags$br(),
          if (!is.na(row$negation_found)) {
            tags$div(
              tags$b("Negation patterns found:"), tags$br(),
              tags$span(class="negation-flag", row$negation_found)
            )
          } else {
            tags$span(style="color:#475569;font-size:12px;", "No negation patterns detected")
          }
      )
    )
  })
  
  output$explain_highlighted <- renderUI({
    req(results(), input$explain_doc)
    doc_id <- as.integer(input$explain_doc)
    text   <- results()$df$text[doc_id]
    highlighted <- highlight_text(text, results()$bing_words)
    HTML(highlighted)
  })
  
  output$explain_lime <- renderPlot({
    req(results(), input$explain_doc)
    doc_id <- as.integer(input$explain_doc)
    wi <- results()$word_importance %>%
      filter(id == doc_id) %>%
      arrange(desc(abs(contribution))) %>%
      head(15) %>%
      mutate(word=fct_reorder(word, contribution),
             direction=ifelse(contribution > 0, "Positive", "Negative"))
    
    if (nrow(wi) == 0) {
      ggplot() +
        annotate("text", x=0.5, y=0.5, label="No sentiment words found in this document",
                 color="#64748b", size=5) +
        theme_dark_vit() + theme(axis.text=element_blank(), axis.title=element_blank())
    } else {
      ggplot(wi, aes(word, contribution, fill=direction)) +
        geom_col(alpha=0.9) +
        geom_text(aes(label=round(contribution,2),
                      hjust=ifelse(contribution>=0,-0.15,1.1)),
                  color="#cbd5e1", size=3.5) +
        scale_fill_manual(values=c(Positive="#22c55e", Negative="#ef4444")) +
        coord_flip() +
        expand_limits(y=c(min(wi$contribution)*1.2, max(wi$contribution)*1.3)) +
        labs(x=NULL, y="AFINN contribution (count × score)",
             title=paste("Word importance — document", doc_id),
             subtitle="Bars show which words pushed sentiment positive or negative",
             fill="Direction") +
        theme_dark_vit()
    }
  })
  
  output$explain_scores <- renderUI({
    req(results(), input$explain_doc)
    doc_id <- as.integer(input$explain_doc)
    row    <- results()$df[doc_id, ]
    
    make_score_row <- function(label, val, color) {
      bar_pct <- min(100, abs(val) / 10 * 100)
      bar_col <- ifelse(val >= 0, "#22c55e", "#ef4444")
      tags$div(style="margin-bottom:14px;",
               tags$div(style="display:flex;justify-content:space-between;margin-bottom:4px;",
                        tags$span(label, style="font-size:12px;color:#94a3b8;"),
                        tags$span(round(val,3), style=paste0("font-size:13px;font-weight:700;color:",ifelse(val>=0,"#22c55e","#ef4444"),";"))
               ),
               tags$div(style="background:#1e3a5f;border-radius:4px;height:6px;overflow:hidden;",
                        tags$div(style=paste0("background:",bar_col,";height:6px;width:",bar_pct,"%;border-radius:4px;"))
               )
      )
    }
    
    tags$div(
      make_score_row("AFINN",   row$score_afinn,   "#38bdf8"),
      make_score_row("Bing",    row$score_bing,    "#22c55e"),
      make_score_row("NRC",     row$score_nrc,     "#a78bfa"),
      make_score_row("Syuzhet", row$score_syuzhet, "#fb923c"),
      tags$hr(style="border-color:#1e3a5f;"),
      tags$div(style="font-size:11px;color:#475569;line-height:1.6;",
               "Score bars normalised to ±10 range. Green = positive signal, red = negative signal."
      )
    )
  })
  
  # ══════════════════════════════════════════════════════════
  # NEW: CONFUSION MATRIX SERVER LOGIC
  # ══════════════════════════════════════════════════════════
  
  output$conf_placeholder <- renderUI({
    df <- results()$df
    if (!"label" %in% names(df)) {
      div(class="insight-box",
          icon("circle-info"), " ",
          "Confusion matrix requires ground-truth labels. Load a built-in dataset (all 6 include labels) or upload a CSV with a second column."
      )
    }
  })
  
  output$conf_matrix <- renderPlot({
    req(results()$conf_data)
    cd <- results()$conf_data
    
    CLASS_ORDER <- c("Positive","Negative","Neutral")
    cd$label     <- factor(cd$label,     levels=CLASS_ORDER)
    cd$predicted <- factor(cd$predicted, levels=CLASS_ORDER)
    
    ggplot(cd, aes(predicted, label, fill=n)) +
      geom_tile(color="#050e1a", linewidth=1) +
      geom_text(aes(label=n), color="white", fontface="bold", size=7) +
      scale_fill_gradient(low="#0f2744", high="#0ea5e9") +
      scale_x_discrete(position="top") +
      labs(x="Predicted label", y="True label",
           title="Confusion matrix — Syuzhet prediction vs ground truth",
           subtitle="Diagonal = correct predictions. Off-diagonal = misclassifications.") +
      theme_dark_vit() +
      theme(legend.position="none",
            axis.text=element_text(size=13,color="#f1f5f9"),
            panel.grid=element_blank()) +
      coord_fixed()
  })
  
  output$metrics_table <- renderUI({
    req(results()$metrics_data)
    md <- results()$metrics_data
    
    overall_acc <- if ("label" %in% names(results()$df)) {
      round(mean(results()$df$predicted == results()$df$label, na.rm=TRUE) * 100, 1)
    } else NA
    
    tags$div(
      if (!is.na(overall_acc)) {
        div(class="insight-box",
            tags$b("Overall accuracy: "),
            tags$span(paste0(overall_acc, "%"),
                      style="color:#38bdf8;font-weight:800;font-size:16px;")
        )
      },
      tags$div(style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:16px;",
               lapply(1:nrow(md), function(i) {
                 row <- md[i,]
                 col <- switch(row$class, Positive="#22c55e", Negative="#ef4444", "#f59e0b")
                 tags$div(class="metric-card",
                          tags$div(style=paste0("font-size:11px;font-weight:700;color:",col,";margin-bottom:8px;"),
                                   row$class),
                          tags$div(class="metric-val", row$f1),
                          tags$div(class="metric-label", "F1 Score"),
                          tags$hr(style="border-color:#1e3a5f;margin:8px 0;"),
                          tags$div(class="metric-sub", paste0("P: ",row$precision)),
                          tags$div(class="metric-sub", paste0("R: ",row$recall)),
                          tags$div(class="metric-sub", paste0("TP:",row$tp," FP:",row$fp," FN:",row$fn))
                 )
               })
      )
    )
  })
  
  # ══════════════════════════════════════════════════════════
  # NEW: DISAGREEMENT FLAGS SERVER LOGIC
  # ══════════════════════════════════════════════════════════
  
  output$disagree_summary <- renderUI({
    df <- results()$df
    counts <- table(df$disagreement_label)
    n_total  <- nrow(df)
    n_strong <- sum(df$disagreement >= 2, na.rm=TRUE)
    n_neg    <- sum(!is.na(df$negation_found))
    
    tags$div(
      div(class="insight-box",
          tags$b("Documents with disagreement: "),
          tags$span(paste0(n_strong, " / ", n_total),
                    style="color:#f97316;font-weight:700;font-size:15px;")
      ),
      div(class="insight-box",
          tags$b("Negation patterns flagged: "),
          tags$span(n_neg, style="color:#a78bfa;font-weight:700;font-size:15px;")
      ),
      div(class="insight-box",
          tags$b("Agreement breakdown:"), tags$br(),
          lapply(c("Unanimous","Slight","Moderate","Strong"), function(lvl) {
            cls <- switch(lvl,
                          Unanimous="badge-unanimous", Slight="badge-slight",
                          Moderate="badge-moderate",   Strong="badge-strong"
            )
            n <- if (!is.null(counts[lvl])) counts[lvl] else 0
            tags$div(style="margin:3px 0;",
                     tags$span(class=paste("disagree-badge", cls), lvl),
                     tags$span(paste0(" — ", n, " docs"),
                               style="color:#64748b;font-size:12px;margin-left:6px;")
            )
          })
      )
    )
  })
  
  output$disagree_bar <- renderPlot({
    df <- results()$df %>%
      count(disagreement_label, predicted) %>%
      mutate(disagreement_label = factor(disagreement_label,
                                         levels=c("Unanimous","Slight","Moderate","Strong")))
    ggplot(df, aes(disagreement_label, n, fill=predicted)) +
      geom_col(position="stack", alpha=0.85) +
      scale_fill_manual(values=SENT_COLORS) +
      labs(x="Disagreement level", y="Document count",
           fill="Predicted",
           title="Lexicon disagreement level by predicted sentiment class") +
      theme_dark_vit()
  })
  
  output$disagree_top <- renderUI({
    n_strong <- sum(results()$df$disagreement >= 2, na.rm=TRUE)
    if (n_strong == 0) {
      div(class="insight-box", "No documents with moderate or strong disagreement found in this corpus.")
    }
  })
  
  output$disagree_table <- renderDT({
    df <- results()$df %>%
      filter(disagreement_flag) %>%
      select(id, text, predicted, disagreement_label, score_afinn, score_bing, score_nrc, score_syuzhet) %>%
      rename(AFINN=score_afinn, Bing=score_bing, NRC=score_nrc, Syuzhet=score_syuzhet,
             Agreement=disagreement_label)
    datatable(df,
              options=list(pageLength=8, scrollX=TRUE,
                           columnDefs=list(list(width="280px",targets=1))),
              rownames=FALSE, class="display compact") %>%
      formatRound(c("AFINN","Bing","NRC","Syuzhet"), digits=3)
  })
  
  output$negation_table <- renderDT({
    df <- results()$df %>%
      filter(!is.na(negation_found)) %>%
      select(id, text, predicted, negation_found, score_syuzhet) %>%
      rename(Negation=negation_found, Syuzhet=score_syuzhet)
    datatable(df,
              options=list(pageLength=8, scrollX=TRUE,
                           columnDefs=list(list(width="280px",targets=1))),
              rownames=FALSE, class="display compact") %>%
      formatRound("Syuzhet", digits=3)
  })
  
  # ── Raw table ─────────────────────────────────────────────
  output$raw_table <- renderDT({
    df <- results()$df %>%
      select(id, text, predicted, score_afinn, score_bing, score_nrc, score_syuzhet,
             disagreement_label, joy, sadness, anger, fear, trust, anticipation,
             any_of("label")) %>%
      rename(AFINN=score_afinn, Bing=score_bing, NRC=score_nrc, Syuzhet=score_syuzhet,
             Agreement=disagreement_label)
    datatable(df,
              options=list(pageLength=15, scrollX=TRUE,
                           columnDefs=list(list(width="300px",targets=1))),
              rownames=FALSE, class="display compact") %>%
      formatRound(c("AFINN","Bing","NRC","Syuzhet","joy","sadness","anger","fear","trust","anticipation"),digits=3)
  })
  
  # ── Downloads — analysis ──────────────────────────────────
  output$dl_res     <- downloadHandler(filename=function()paste0("results_",Sys.Date(),".csv"),
                                       content=function(f)write.csv(results()$df,f,row.names=FALSE))
  output$dl_tokens  <- downloadHandler(filename=function()paste0("tokens_",Sys.Date(),".csv"),
                                       content=function(f)write.csv(results()$tokens,f,row.names=FALSE))
  output$dl_bigrams <- downloadHandler(filename=function()paste0("bigrams_",Sys.Date(),".csv"),
                                       content=function(f)write.csv(results()$bigrams,f,row.names=FALSE))
  output$dl_flags   <- downloadHandler(filename=function()paste0("disagreement_flags_",Sys.Date(),".csv"),
                                       content=function(f)write.csv(
                                         results()$df %>% filter(disagreement_flag | !is.na(negation_found)),
                                         f, row.names=FALSE))
  
  # ── Downloads — sample CSVs ───────────────────────────────
  make_dl <- function(key)
    downloadHandler(filename=function()paste0("sample_",key,".csv"),
                    content=function(f)write.csv(DATASETS[[key]]$data,f,row.names=FALSE))
  
  output$dl_s_imdb    <- make_dl("imdb")
  output$dl_s_twitter <- make_dl("twitter")
  output$dl_s_amazon  <- make_dl("amazon")
  output$dl_s_reddit  <- make_dl("reddit")
  output$dl_s_news    <- make_dl("news")
  output$dl_s_support <- make_dl("support")
}

shinyApp(ui, server)
