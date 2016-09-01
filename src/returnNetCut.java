import org.ucl.conf.ConfAssign;

class returnNetCut
{
  public static void main(String args[])
  {
      if( args.length != 2 )
      {
            System.out.println( "usage: java returnNetCut.java [CU|CA|FE|ZN|MG|MN] [0|1|2|3]" );
            System.exit(1);
      }

      String strMetType = args[0];
      Integer intMetIndex = 0;
      Integer intFPRindex = 0;
      try
      {
        intFPRindex = Integer.parseInt(args[1]);
      }
      catch(Exception ex)
      {
        System.out.println("Second arg can not be cast as integer, choices are [0|1|2|3]");
        System.exit(1);
      }
      if(intFPRindex > 3)
      {
        System.out.println("Second arg out of range, choices are [0|1|2|3]");
        System.exit(1);
      }
      if(strMetType.equals("CU"))
        intMetIndex = 0;
    	if(strMetType.equals("CA"))
        intMetIndex = 1;
    	if(strMetType.equals("FE"))
        intMetIndex = 2;
    	if(strMetType.equals("ZN"))
        intMetIndex = 3;
      if(strMetType.equals("MG"))
        intMetIndex = 4;
      if(strMetType.equals("MN"))
        intMetIndex = 5;
      ConfAssign conf = new ConfAssign(intMetIndex);
	    double fprNetCut = conf.cutCalc(intFPRindex);
      String strNetCut = Double.toString(fprNetCut);
      System.out.println("    FPR CUTOFF    " + strNetCut);
  }
}
