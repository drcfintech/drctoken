#!/usr/bin/env node

'use strict';

var timeseconds = new Date(2018,4,7,9,0,0).getTime() / 1000 + 86400 * 0;
console.log(timeseconds);
console.log(86400 * 365 * 2);
console.log(Math.round((Date.now() + 60 * 1000) / 1000));
//var nowtime = new Date().getTime() / 1000;
//console.log(nowtime);
//var newtime = new Date(1520867875 * 1000);
//console.log(newtime);
//var endtime = new Date(2018, 2, 12, 14, 5, 17).getTime() / 1000;
//var mul = (1520867875 - endtime) / 600;
//console.log(mul);

