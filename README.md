# ActBlue 1378435

This repository contains curated bulk data and sample analysis provided by [Circa Victor](https://circavictor.com). Please feel free to share and report on this information as you see fit. All we ask is that you please cite us in your investigative articles. Our goal is to deliver actionable data through increased comprehension and quality analysis.

Need more in-depth analysis? Email us at [team@circavictor.com](mailto:team@circavictor.com).

## By the Numbers

**Committee**: [ActBlue](https://secure.actblue.com/)

**FECfile**: [1378435](https://www.fec.gov/data/committee/C00401224/?tab=filings)

**filed**: January 31st, 2020

**size**: ~ 9.7gb

**data points**: 44,627,333

**contributions**: 24,656,453

**volume**: $525,124,217.30

**contribution avg**: $21.30

**unique recipient committees**: 1,844

**unique individuals**: 4,422,861

**unique locations**: 3,875,357

**unique zipcodes**: 39,359

## Analysis
  * [Principal Committees by total](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/principal-committees-overall.csv)
  * [Principal Committees by avg](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/principal-committee-avg.csv)
  * [Individual contributors by total](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/contributor-individuals-overall.csv)
  * [Individual contributors by average >= 5 contributions](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/contributor-individuals-avg.csv)
  * [Recipient Committees by total](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/committees-overall.csv)
  * [Recipient Committees by average](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/committees-avg.csv)
  * [States by overall total](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/states-overall.csv)
  * [States by average](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/states-avg.csv)
  * [Zipcodes by overall total](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/zip_codes-overall.csv)
  * [Zipcodes by average >= 250 contributions](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/zip_codes-avg.csv)
  * [Direct contributions to ActBlue](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/actblue-contributions.csv)
  * [Future nominee contributions](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/actblue-future-nominees.csv)
  * [Form types breakdown](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/form_types.csv)

## Why?

There currently exists a **HUGE** gap in accurate timely reporting around all things Campaign Finance. We feel that it's every citizen's right to be accurately informed in a timely manner. Exporting this dataset to the public is a statement to that commitment.

## Who?

Hello, nice to meet you, we are team [Circa Victor](https://circavictor.com). 

Looking for more? Contact us at [team@circavictor.com](mailto:team@circavictor.com).

## Data Breakdown

For quicker reporting and easier consumation, the data has been broken down into separate [csv files by state](https://github.com/CircaVictor/actblue-analysis-1378435/tree/master/data/states). Take a look at the [state volume analysis](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/analysis/states-overall.csv) to see how many transactions are available for your state.

*fyi*: in order to reduce the csv file size, recipient committees have been abstracted down to their FEC id.

* [Contributions by State](https://github.com/CircaVictor/actblue-analysis-1378435/tree/master/data/states)
  * individual id - contributor individual id
  * location id - the contribution origin location. multiple individuals may be at the same location
  * first name - contributor's first initial
  * last name - contributor's last
  * amount - contribution amount
  * contributed date - the date that this contribution was made
  * recipient committee fec id - the FEC committee id of the 
  * transction id - the transaction id filed by ActBlue
  * contribution aggregate - total aggregate this individual has given
  * memo - memo text for the contribution. may contain additional insights
  * zip code - the zipcode where contribution originated
  * state - the state where the contribution came from
* [Recipient Committees](https://github.com/CircaVictor/actblue-analysis-1378435/blob/master/data/recipient_committees.csv)
  * fec id - the committee FEC id. you can match this field to the recipient commitee fec id in state contributions
  * name - committee name
  * candidate fec id - if attached to a candidate, the candidate's FEC id
  * candidate name - name of candidate attached to this committee
  * affilation - candidate / committeee affiliation. democrat, republican, etc.
  * office - office which this candidate holds or is seeking
  * state - state where this office is located
  * district - state district that this candidate is representing if House candidate
  * incumbent or challenger? - is this candidate an (i) incumbent, (c) challenger or (o) open seat
  * is authorized committee? - is this a committee authorized by the candidate
  * is principal committee? - is this a principal committee directly attached to a candidate


