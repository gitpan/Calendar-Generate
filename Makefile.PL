use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Calendar::Generate',
    VERSION_FROM      => 'lib/Calendar/Generate.pm', # finds $VERSION
    PREREQ_PM         => { Date::Calc => 5.3, }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Calendar/Generate.pm', # retrieve abstract from module
       AUTHOR         => 'Clint Moore <cmoore@cpan.org>') : ()),
);
