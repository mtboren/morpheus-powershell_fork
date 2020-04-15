## Some Changes Towards Standard

Some things to do to make the module a bit closer to a standard layout / model
- Make single module -- use multiple modules only for overall module size consideration (like MBs big; less than 100KB?  Probably need not involve that additional complexity, yet)
    - simplifies module manifest creation code a bit, too (single .psd1)
- Publish to the PowerShell Gallery for ease of install/update by consumers
- Write `<language>\about_module.txt` help file, so that people can get the general help about the module (outside of just per-cmdlet help)

Other things to add/replace eventually
- Real types, versus typename array insertion that works in some ways, but does not make a true object of said type
    - this might involve PowerShell Class definitions, or .NET type definitions
- Add support for connecting to multiple Morpheus servers
    - this might include adding global variable in which connection info is kept, not only foruse by module, but so that user can use the connection info object(s), too (a la `VMWare.PowerCLI` module for its VIServer connection(s), or the AWS PowerShell modules for the currently "in use" AWS Account)
    - would likely use a bit more module-specific variables names (vs. `URL`, `Header`), so as to prevent possibly overwriting user's existing variables
- Add support for disconnecting from a Morpheus server (terminate Morpheus session if that is a thing, but even if "disconnecting" is just clearing local variables in the user's PowerShell session, do that)
- Replace `Check-Flags` with other filtering code (if needed at all?)
- Remove local filesystem references (unless we expect everyone to have `C:\Users\Matt`, for example)
- Add Argument Completers, so that people can be even more productive/optimized at the command line (tab-completion of values from the Morpheus environment itself -- Workflow names, Cloud names, etc.)
- Avoid changing default environment items (like `$FormatEnumerationLimit`) unless super good reason (may already be a great reason to do so)