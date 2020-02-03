# README

This repository contains curated bulk data and sample analysis provided by [Circa Victor](https://circavictor.com). Please feel free to share and use this information as you see fit. All we ask is that you please cite us in your investigative reporting.

Looking for more? Email us at [team@circavictor.com](mailto:team@circavictor.com).

## By the Numbers

**FECfile**: 1378435

**filed**: January 31st, 2020

**size**: ~ 9.7gb

**data points**: 44,627,333

**contributions**: 24,721,651

**volume**:

**contribution avg**:

**unique recipient committees**:

**unique contributors**:

**unique locations**:

**unique zipcodes**:

## Sample Analysis
  * Contributors by overall total
  * Contributors by average >= 5 contributions
  * Recipient Committees by overall total
  * Recipient Committees by average
  * States by overall total
  * States by average
  * Zipcodes by overall total
  * Zipcodes by average >= 250 contributions
  * Direct contributions to ActBlue
  * Future nominee contributions

## Why?

Currently, there exists a HUGE gap in accurate timely reporting around all Campaign Finance. We feel that it's every citizen's right to be accurately informed in a timely manner. Exporting this dataset to the public is a statement to that commitment.

## Who?

Hello, nice to meet you. We are [Circa Victor](https://circavictor.com). 

Need more in-depth analysis? Contact us at [team@circavictor.com](mailto:team@circavictor.com).

## Data Breakdown

For quicker reporting and easier consumation, the data has been broken down into separate csv files by state.

* Contributions by State
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
* Recipient Committees
  * fec id - the committee FEC id
  * name - committee name
  * candidate fec id - if attached to a candidate, the candidate's FEC id
  * candidate name - name of candidate attached to this committee
  * affilation - candidate / committeee affiliation. democrat, republican, etc.
  * office - office which this candidate holds or is seeking
  * state - state where this office is located
  * district - state district that this candidate is representing if House candidate
  * incumbent or challenger? - is this candidate an incumbent (i) or challenger (c)
  * is authorized committee? - is this a committee authorized by the candidate
  * is principal committee? - is this a principal committee directly attached to a candidate


