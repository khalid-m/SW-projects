package Goovi;

import java.util.*;

/**
  * Class for handling dynamic lists of strings in a typesafe manner.
  *
  * @author Kristofer Cassel
  */
public class StringVector extends ArrayList
{
  public StringVector()
  {
    super();
  }

  /**
    * Create a StringVector with the initial capacity n
    */
  public StringVector(int n)
  {
    super(n);
  }

  /**
    * Create a StringVector with one element str
    */
  public StringVector(String str)
  {
    super();
    add(str);
  }

  /**
    * Create a StringVector with two elements str1, str2
    */
  public StringVector(String str1, String str2)
  {
    this(str1);
    add(str2);
  }

    /**
    * Create a StringVector with three elements str1, str2, str3
    */
  public StringVector(String str1, String str2, String str3)
  {
    this(str1, str2);
    add(str3);
  }

    /**
    * Create a StringVector with four elements str1, str2, str3, str4
    */
  public StringVector(String str1, String str2, String str3, String str4)
  {
    this(str1, str2, str3);
    add(str4);
  }

  
    /**
    * Create a StringVector with five elements str1, str2, str3, str4, str5
    */
  public StringVector(String str1, String str2, String str3, String str4, String str5)
  {
    this(str1, str2, str3, str4);
    add(str5);
  }

  /**
    * Retrieve element at position i
    *
    * @returns the string element at pos i
    */
  public final String at(int i)
  {
    return super.get(i).toString();
  }

  /**
    * Add this string to the end of the StringVector
    *
    * @param str the string to add
    */
  public final void add(String str)
  {
    super.add(str);
  }

   /**
    * Set the element at the specified position
    *
    * @param i the position in the StringVector
    * @param str the string element to put in
    */
  public final void set(int i, String str)
  {
    super.set(i, str);
  }
}