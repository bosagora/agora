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

struct FileBasedLock
{

    ///
    private string lock_file_name;

    ///
    private string lock_file_dir;
    
    ///
    private string lock_file_path;
    
    ///
    private File lock_file; 

    /// 
    private bool create_dir;

    /***************************************************************************

        Creates a FileBasedLock object

        Params:
            lock_file_name = name of the lock file
            lock_file_dir = the directory where the lock file has to be created
            create_dir = true, if the directory holding the lock file 
                         needs to be created

        Returns:
            Returns `FileBasedLock` object

    ***************************************************************************/

    public this (string lock_file_name, string lock_file_dir = tempDir(), bool create_dir = false)
    {	
        this.lock_file_name = lock_file_name;
        this.lock_file_dir = lock_file_dir;
        this.create_dir = create_dir;
        this.lock_file_path = buildPath(lock_file_dir, lock_file_name);
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
                if(!lock_file.tryLock(LockType.readWrite, 0, 0)) 
                    throw new Exception(format("unable to lock file: %s", lock_file_path));
                return true;
            });
    }

    /***************************************************************************

        Attempts to lock the file and blocks until the lock is acquired

    ***************************************************************************/

    public void lockBlock ()
    { 
        lock({
                lock_file.lock(LockType.readWrite, 0, 0);
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
                return lock_file.tryLock(LockType.readWrite, 0, 0);
            });
    }

    /***************************************************************************

        Unlocks the file

    ***************************************************************************/
    
    public void unlock ()
    {
        lock_file.unlock();	
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
        if(create_dir)
            mkdirRecurse(lock_file_dir);

        // 1. if the file doesn't exists, then the File's constructor will create it
        // 2. it the file exists and an other process has already acquired 
        //    an excusive log to it, we can still open it for writing
        lock_file = File(lock_file_path,"w"); 
        auto ret_val = lock_delegate();
        
        // writing the PID of the current process into the lock file to help debugging
        lock_file.write(getpid()); 
        lock_file.flush();

        return ret_val;
    }
}
