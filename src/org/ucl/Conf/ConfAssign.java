/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.ucl.conf;

/**
 *
 * @author dbuchan
 */

import java.util.*;
import java.io.*;


public class ConfAssign{

    public int metType;
    public double liklihood;
    public double cutVal;


    public final static double[] CU_ION = {-4.078546e+00, 1.372440e+02, -1.707557e+03, 1.206672e+04, -5.082740e+04, 1.313278e+05, -2.092141e+05, 2.000059e+05, -1.051337e+05, 2.335553e+04};
    public final static double[] CA_ION = {-1.984715, 26.338884, -101.636073, 206.801412, -199.963936, 74.115255};
    public final static double[] FE_ION = {-1.660575, 26.497937, -113.945899, 249.943351, -247.328744, 90.059971};
    public final static double[] MG_ION = {-1.261588, 13.867528, -55.702195, 138.240261, -153.118192, 62.698153};
    public final static double[] MN_ION = {-1.757852, 24.898865, -101.855584, 216.052410, -213.172852, 80.304448};
    public final static double[] ZN_ION = {-1.659959, 16.042996, -45.951094, 90.124845, -92.969694, 39.510643};

    public final static double[] CU_CUT = {0.743,0.349,0.182,0.073};
    public final static double[] CA_CUT = {0.704,0.432,0.292,0.164};
    public final static double[] FE_CUT = {0.769,0.352,0.175,0.069};
    public final static double[] ZN_CUT = {0.716,0.38,0.238,0.13};
    public final static double[] MG_CUT = {0.653,0.392,0.275,0.173};
    public final static double[] MN_CUT = {0.727,0.397,0.246,0.126};


    public final static double[][] allLR = {CU_ION,CA_ION,FE_ION,ZN_ION,MG_ION,MN_ION};

    public final static double[][] allCUTS = {CU_CUT,CA_CUT,FE_CUT,ZN_CUT,MG_CUT,MN_CUT};

    public ConfAssign(int type){

	metType = type;

    }

    public double getLogLRatio(double net_value) {

	double[] metal_ion = allLR[metType];

        double result = 0;

        /* General N-th order polynomial */
        for (int i = metal_ion.length - 1; i > 0; i--) {
            result = (result + metal_ion[i]) * net_value;
        }
        result += metal_ion[0];

        return result;
    }

    public double cutCalc(int fpr){

	double[] metal_ion = allCUTS[metType];

	double netCut = metal_ion[fpr];
	return netCut;
    }

    public static void main(String args[])
    {
        try
	    {
            ConfAssign test = new ConfAssign(1);
            double cut = test.cutCalc(1);
            //System.out.println(cut);
	    }
        catch( Exception e )
        {
            System.err.println( e );
        }

    }



}
