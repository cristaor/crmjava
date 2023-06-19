package com.knowgate.clocial;

import java.io.FileNotFoundException;
import java.io.IOException;

import com.knowgate.storage.Engine;
import com.knowgate.storage.SchemaMetaData;

public final class ModelManager { 

  public ModelManager() {
  }
  
  public void createPackage(Engine eEng, String sProfile, String sPackage) throws FileNotFoundException, ClassNotFoundException, IOException {
	SchemaMetaData oSch = new SchemaMetaData(sPackage);
	switch (eEng) {
      case JDBCRDBMS:
    	
    }
  }
}
