**What is moving average;

**https://blogs.sas.com/content/iml/2016/01/25/moving-average.html;
**https://blogs.sas.com/content/iml/2016/01/27/moving-average-in-sas.html (using proc expand)
**http://support.sas.com/kb/25/027.html (using datastep)

**other references: http://support.sas.com/resources/papers/proceedings10/093-2010.pdf;


/* Create sample data */
data x; 
  do x=1 to 10; 
    output; 
  end; 
run;
proc print data=x; run;

/* Sample 1: Compute the moving average of the entire data set */
data avg;
  retain s 0;
  set x;
  s=s+x;
  a=s/_n_;
run;

title 'Moving average of entire data set';
proc print;
run;


/* Sample 2: Compute the moving average of last 5 observations */
%let n = 5;

data avg;
  retain s;
  set x;
  array qwe_(&n);
  do i = &n to 2 by -1;
    qwe_(i)=qwe_(i-1);
  end;
  qwe_(1)=x;
  a = sum(of qwe_(*)) / &n;
  retain qwe_: ;
  drop qwe_: i ;
run;

title 'Moving average of last 5 observations';
proc print;
run;

/* Sample 3: Compute the moving average within a BY-Group of last n observations. */
/* For the first n-1 observations within the BY-Group, the moving average         */
/* is set to missing.                                                             */
data ds1;
  do patient='A','B','C';
    do month=1 to 7;
      num=int(ranuni(0)*10);
      output;
      end;
    end;
run;

proc sort;
  by patient;
run;

%let n = 4;

data ds2;
  set ds1;
  by patient;
  retain num_sum 0;
  if first.patient then do;
    count=0;
    num_sum=0;
  end;
  count+1;
  last&n=lag&n(num);
  if count gt &n then num_sum=sum(num_sum,num,-last&n);
  else num_sum=sum(num_sum,num);
  if count ge &n then mov_aver=num_sum/&n;
  else mov_aver=.;
run;

title 'Moving average within BY-Group';
proc print;
run;
