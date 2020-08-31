/*******************************************************************************

    Implements file based locking that can help synchronize processes

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.FileBasedLock;

import std.file;
import std.format;
import std.path : buildPath;
import std.stdio : File, LockType;

import core.thread.osthread: getpid;

/*******************************************************************************

    Implements file based locking that can help synchronize processes

*******************************************************************************/

public struct FileBasedLock
{
    ///
    public string file_name;
    
    ///
    public string file_path;

    ///
    private string file_dir;
    
    ///
    private File file; 

    /// 
    private bool create_dir;

    /***************************************************************************

        Creates a FileBasedLock object

        Params:
            file_name = name of the lock file
            file_dir = the directory where the lock file has to be created
            create_dir = true, if the directory holding the lock file 
                         needs to be created

        Returns:
            Returns `FileBasedLock` object

    ***************************************************************************/

    public this (string file_name, string file_dir = tempDir(), bool create_dir = false)
    {	
        this.file_name = file_name;
        this.file_dir = file_dir;
        this.create_dir = create_dir;
        this.file_path = buildPath(file_dir, file_name);
    }

    /***************************************************************************

        Attempts to lock the file and throws exception if unsuccessful

        Throws:
            `Exception` if the process couldn't lock the file

    ***************************************************************************/

    public void lockThrow ()
    {		 
        lock({
                // using excusive locks for the entire file
                if (!file.tryLock(LockType.readWrite, 0, 0)) 
                    throw new Exception(format("unable to lock file: %s", file_path));
                return true;
            });
    }

    /***************************************************************************

        Attempts to lock the file and blocks until the lock is acquired

    ***************************************************************************/

    public void lockBlock ()
    { 
        lock({
                file.lock(LockType.readWrite, 0, 0);
                return true;
            });
    }

    /***************************************************************************

        Attempts to lock the file and return immediately

        Returns:
            Returns true if the lock is acquired, false otherwise

    ***************************************************************************/

    public bool lockTry ()
    {
        return 
        lock({
                return file.tryLock(LockType.readWrite, 0, 0);
            });
    }

    /***************************************************************************

        Unlocks the file

    ***************************************************************************/
    
    public void unlock ()
    {
        file.unlock();	
    }

    /***************************************************************************

        Helper function to lock a file

        Params:
            lock_delegate = does the actual locking using `std.stdio.File`

        Returns:
            Returns whatever the `lock_delegate` parameter returns

    ***************************************************************************/

    private bool lock (bool delegate() lock_delegate)
    {
        if (create_dir)
            mkdirRecurse(file_dir);

        // 1. if the file doesn't exists, then the File's constructor will create it
        // 2. it the file exists and an other process has already acquired 
        //    an excusive log to it, we can still open it for writing
        file = File(file_path,"w"); 
        auto ret_val = lock_delegate();
        
        // writing the PID of the current process into the lock file to help debugging
        file.write(getpid()); 
        file.flush();

        return ret_val;
    }
}
