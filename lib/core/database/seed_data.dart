// ─── Seed Data ────────────────────────────────────────────────────────────────
// Firestore seed verisiyle birebir aynı içerik, yerel SQLite için Dart sabiti.

const List<Map<String, dynamic>> kSeedPersonas = [
  {
    'id': 'persona_public',
    'name': 'Public Broadcaster',
    'description':
        'Serves the public interest with balanced, fact-checked journalism.',
    'iconEmoji': '📡',
    'isDefault': 1,
    'sortOrder': 0,
    'bias':
        'Neutral, civic-minded, focuses on public interest and democratic accountability.',
    'ethics':
        'Very high. Strict fact-checking, no sensationalism, balanced perspectives required.',
    'clickbaitThreshold': 15,
  },
  {
    'id': 'persona_tabloid',
    'name': 'Commercial Tabloid',
    'description':
        'Prioritizes clicks, sensationalism, and celebrity gossip above all.',
    'iconEmoji': '🔥',
    'isDefault': 1,
    'sortOrder': 1,
    'bias':
        'Sensationalist. Heavily favors high emotional impact, celebrity gossip, crime, and scandal.',
    'ethics':
        'Low. Will publish unverified rumors if engaging enough. Prioritizes clicks over truth.',
    'clickbaitThreshold': 85,
  },
  {
    'id': 'persona_independent',
    'name': 'Independent',
    'description':
        'Progressive and anti-establishment, amplifying underreported stories.',
    'iconEmoji': '✊',
    'isDefault': 1,
    'sortOrder': 2,
    'bias':
        'Progressive, anti-establishment. Prioritizes underreported stories, activism, and systemic issues.',
    'ethics':
        'High on principles but may take a strong editorial stance.',
    'clickbaitThreshold': 40,
  },
];

const List<Map<String, dynamic>> kSeedNewsPool = [
  {
    'id': 'news_001',
    'headline': 'Mayor Arrested in Bribery Scandal',
    'summary':
        'Exclusive photos reveal the mayor accepting cash from city contractors during a private dinner.',
    'imageUrl': '',
    'category': 'Politics',
    'sensationalismScore': 88,
    'biasIndex': 0,
    'tags': '["corruption","local","breaking"]',
  },
  {
    'id': 'news_002',
    'headline': 'Parliament Passes New Climate Bill',
    'summary':
        'Landmark legislation mandates 60% renewable energy by 2035, dividing business leaders.',
    'imageUrl': '',
    'category': 'Politics',
    'sensationalismScore': 22,
    'biasIndex': -10,
    'tags': '["climate","policy","government"]',
  },
  {
    'id': 'news_003',
    'headline': 'Celebrity Couple Spotted After Breakup Rumors',
    'summary':
        'A-list stars were seen holding hands in Milan, silencing weeks of split speculation.',
    'imageUrl': '',
    'category': 'Celebrity',
    'sensationalismScore': 92,
    'biasIndex': 0,
    'tags': '["celebrity","romance","exclusive"]',
  },
  {
    'id': 'news_004',
    'headline': 'New Study Links Ultra-Processed Foods to Dementia',
    'summary':
        'A landmark 20-year study of 200,000 adults finds strong correlation between diet and cognitive decline.',
    'imageUrl': '',
    'category': 'Science',
    'sensationalismScore': 45,
    'biasIndex': 0,
    'tags': '["health","science","diet"]',
  },
  {
    'id': 'news_005',
    'headline': 'Stock Market Crashes 8% in Single Day',
    'summary':
        'Panic selling triggered by surprise interest rate hike wiped out \$2 trillion in market value.',
    'imageUrl': '',
    'category': 'Economy',
    'sensationalismScore': 72,
    'biasIndex': 15,
    'tags': '["finance","crash","economy"]',
  },
  {
    'id': 'news_006',
    'headline': 'Teachers\' Union Calls for National Strike',
    'summary':
        'Hundreds of thousands of teachers plan to walk out over stagnant wages and classroom overcrowding.',
    'imageUrl': '',
    'category': 'Politics',
    'sensationalismScore': 55,
    'biasIndex': -20,
    'tags': '["education","strike","labor"]',
  },
  {
    'id': 'news_007',
    'headline': 'Serial Killer Captured After 15 Years',
    'summary':
        'DNA technology led police to a suspect linked to 11 unsolved murders across three states.',
    'imageUrl': '',
    'category': 'Crime',
    'sensationalismScore': 95,
    'biasIndex': 0,
    'tags': '["crime","murder","breaking"]',
  },
  {
    'id': 'news_008',
    'headline': 'Tech Giant Fined \$4.2 Billion for Data Privacy Violations',
    'summary':
        'The EU\'s largest-ever fine follows a 3-year investigation into illegal user data harvesting.',
    'imageUrl': '',
    'category': 'Economy',
    'sensationalismScore': 38,
    'biasIndex': -15,
    'tags': '["tech","privacy","EU"]',
  },
  {
    'id': 'news_009',
    'headline': 'Olympic Champion Admits to Doping',
    'summary':
        'Gold medalist confesses to using banned substances during the last three championships.',
    'imageUrl': '',
    'category': 'Sports',
    'sensationalismScore': 80,
    'biasIndex': 0,
    'tags': '["sports","scandal","olympics"]',
  },
  {
    'id': 'news_010',
    'headline': 'Refugee Crisis Reaches Critical Level at Border',
    'summary':
        'Aid organizations warn of a humanitarian catastrophe as 50,000 refugees await processing.',
    'imageUrl': '',
    'category': 'Politics',
    'sensationalismScore': 60,
    'biasIndex': -25,
    'tags': '["refugees","border","humanitarian"]',
  },
  {
    'id': 'news_011',
    'headline': 'Scientists Discover Potential Cure for Alzheimer\'s',
    'summary':
        'A protein-based therapy has shown 70% effectiveness in reversing early-stage Alzheimer\'s in trials.',
    'imageUrl': '',
    'category': 'Science',
    'sensationalismScore': 30,
    'biasIndex': 0,
    'tags': '["alzheimers","medicine","breakthrough"]',
  },
  {
    'id': 'news_012',
    'headline': 'Reality TV Star\'s Mansion Burns Down in Malibu Fire',
    'summary':
        'The influencer and her dogs escaped safely, but \$15 million in property was destroyed.',
    'imageUrl': '',
    'category': 'Celebrity',
    'sensationalismScore': 89,
    'biasIndex': 0,
    'tags': '["fire","celebrity","malibu"]',
  },
  {
    'id': 'news_013',
    'headline': 'Central Bank Raises Interest Rates for Fifth Time',
    'summary':
        'The move aims to curb inflation but risks pushing the economy into recession, analysts warn.',
    'imageUrl': '',
    'category': 'Economy',
    'sensationalismScore': 18,
    'biasIndex': 10,
    'tags': '["economy","interest rates","inflation"]',
  },
  {
    'id': 'news_014',
    'headline': 'Whistleblower Reveals Government Surveillance Program',
    'summary':
        'Leaked documents show intelligence agencies monitored millions of citizens\' social media without warrants.',
    'imageUrl': '',
    'category': 'Politics',
    'sensationalismScore': 75,
    'biasIndex': -30,
    'tags': '["surveillance","government","privacy"]',
  },
  {
    'id': 'news_015',
    'headline': 'National Football League Announces Overseas Expansion',
    'summary':
        'Three new international franchises will be added to the league by 2027, expanding into Europe.',
    'imageUrl': '',
    'category': 'Sports',
    'sensationalismScore': 35,
    'biasIndex': 0,
    'tags': '["sports","football","expansion"]',
  },
  {
    'id': 'news_016',
    'headline': 'Drug Cartel Boss Escapes from Maximum Security Prison',
    'summary':
        'A tunnel discovered under the prison was reportedly used by 12 armed guards to aid the escape.',
    'imageUrl': '',
    'category': 'Crime',
    'sensationalismScore': 97,
    'biasIndex': 0,
    'tags': '["crime","prison","escape"]',
  },
  {
    'id': 'news_017',
    'headline': 'Local Farmer Grows World\'s Heaviest Pumpkin',
    'summary':
        'A retired engineer from Idaho broke the world record with a 1,400-pound pumpkin at the state fair.',
    'imageUrl': '',
    'category': 'Human Interest',
    'sensationalismScore': 10,
    'biasIndex': 0,
    'tags': '["record","farming","quirky"]',
  },
  {
    'id': 'news_018',
    'headline': 'AI System Outperforms Radiologists in Cancer Detection',
    'summary':
        'A new deep learning model detected early-stage lung cancer with 94.5% accuracy in clinical trials.',
    'imageUrl': '',
    'category': 'Science',
    'sensationalismScore': 40,
    'biasIndex': 0,
    'tags': '["AI","medicine","cancer"]',
  },
  {
    'id': 'news_019',
    'headline': 'Housing Prices Drop 15% Amid Developer Bankruptcy',
    'summary':
        'Thousands of homeowners face negative equity as a major property developer collapses.',
    'imageUrl': '',
    'category': 'Economy',
    'sensationalismScore': 65,
    'biasIndex': 5,
    'tags': '["housing","economy","bankruptcy"]',
  },
  {
    'id': 'news_020',
    'headline': 'Pop Star Shaves Head, Posts Tearful Video Online',
    'summary':
        'The Grammy-winner\'s emotional meltdown has sparked widespread debate about celebrity mental health.',
    'imageUrl': '',
    'category': 'Celebrity',
    'sensationalismScore': 87,
    'biasIndex': 0,
    'tags': '["celebrity","mental health","viral"]',
  },
  {
    'id': 'news_021',
    'headline': 'UN Report: Ocean Plastics Will Outweigh Fish by 2035',
    'summary':
        'The damning report calls for an immediate global treaty on single-use plastic manufacturing.',
    'imageUrl': '',
    'category': 'Science',
    'sensationalismScore': 50,
    'biasIndex': -10,
    'tags': '["ocean","plastic","environment"]',
  },
  {
    'id': 'news_022',
    'headline': 'Brutal Gang War Leaves 18 Dead in Capital City',
    'summary':
        'A violent territorial dispute between two rival factions erupted in daylight in the city center.',
    'imageUrl': '',
    'category': 'Crime',
    'sensationalismScore': 96,
    'biasIndex': 5,
    'tags': '["crime","gang","violence"]',
  },
  {
    'id': 'news_023',
    'headline': 'Government Proposes Cutting Pension Benefits by 20%',
    'summary':
        'Citing budget deficits, officials argue cuts are necessary; retiree groups plan mass protests.',
    'imageUrl': '',
    'category': 'Politics',
    'sensationalismScore': 55,
    'biasIndex': 20,
    'tags': '["pensions","budget","protests"]',
  },
  {
    'id': 'news_024',
    'headline': 'Space Agency Confirms Evidence of Water on Mars',
    'summary':
        'Satellite data reveals vast underground reservoirs, reigniting hopes for future human colonization.',
    'imageUrl': '',
    'category': 'Science',
    'sensationalismScore': 42,
    'biasIndex': 0,
    'tags': '["mars","space","water"]',
  },
  {
    'id': 'news_025',
    'headline': 'Viral Video Shows Police Brutality at Protest',
    'summary':
        'The footage, viewed 40 million times, shows officers using force on peaceful demonstrators.',
    'imageUrl': '',
    'category': 'Politics',
    'sensationalismScore': 82,
    'biasIndex': -35,
    'tags': '["police","protest","brutality"]',
  },
  {
    'id': 'news_026',
    'headline': 'Billionaire Proposes to Supermodel on Private Island',
    'summary':
        'The tech mogul\'s elaborate 7-figure proposal was livestreamed to 2 million viewers on social media.',
    'imageUrl': '',
    'category': 'Celebrity',
    'sensationalismScore': 76,
    'biasIndex': 0,
    'tags': '["celebrity","billionaire","romance"]',
  },
  {
    'id': 'news_027',
    'headline': 'Factory Workers Expose Dangerous Chemical Dumping',
    'summary':
        'Employees at a chemical plant have secretly documented illegal toxic waste being dumped in local rivers.',
    'imageUrl': '',
    'category': 'Politics',
    'sensationalismScore': 62,
    'biasIndex': -20,
    'tags': '["environment","corporate","whistleblower"]',
  },
  {
    'id': 'news_028',
    'headline': 'National Unemployment Rate Drops to Historic Low',
    'summary':
        'The 3.1% unemployment rate, the lowest in 50 years, is attributed to green energy sector growth.',
    'imageUrl': '',
    'category': 'Economy',
    'sensationalismScore': 15,
    'biasIndex': -5,
    'tags': '["economy","jobs","employment"]',
  },
  {
    'id': 'news_029',
    'headline': 'Child Star\'s Parents Arrested for Financial Exploitation',
    'summary':
        'Investigators allege the parents siphoned over \$8 million from their teenage son\'s acting career.',
    'imageUrl': '',
    'category': 'Crime',
    'sensationalismScore': 85,
    'biasIndex': 0,
    'tags': '["crime","celebrity","child abuse"]',
  },
  {
    'id': 'news_030',
    'headline': 'City Plans to Ban Cars from Historic Downtown District',
    'summary':
        'The controversial green initiative aims to cut emissions but has angered business owners and commuters.',
    'imageUrl': '',
    'category': 'Politics',
    'sensationalismScore': 30,
    'biasIndex': -15,
    'tags': '["environment","city","transport"]',
  },
];
