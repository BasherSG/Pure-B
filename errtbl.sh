#!/usr/bin/env bash

declare -rgA ERRTBL=( 
    ['GNRL_ERR']=1
    ['BLTIN_ERR']=2
    ['MISS_DEPEND']=3
    ['BAD_USAGE']=4
    ['CANT_DO']=5
    ['BAD_ARG']=6
    ['NO_FILE']=7
    ['NO_FOLD']=8
    ['LOCK_ON']=9
    ['BAD_FILE']=10
    ['BAD_FOLD']=11
    ['NOT_EXIST']=12
    ['CANT_READ']=13
    ['BAD_COLOR']=14
    ['MDL_FATAL']=101
    ['CMD_EXC_ERR']=126
    ['CMD_NOT_FOUND']=127
    ['EXIT_BAD_ARG']=128
    ['SIGHUP']=129
    ['SIGINT']=130
    ['SIGQUIT']=131
    ['SIGILL']=132
    ['SIGTRAP']=133
    ['SIGABRT']=134
    ['SIGBUS']=135
    ['SIGFPE']=136
    ['SIGKILL']=137
    ['SIGUSR1']=138
    ['SIGSEGV']=139
    ['SIGUSR2']=140
    ['SIGPIPE']=141
    ['SIGALRM']=142
    ['SIGTERM']=143
    ['SIGSTKFLT']=144
    ['SIGCHLD']=145
    ['SIGCONT']=146
    ['SIGSTOP']=147
    ['SIGTSTP']=148
    ['SIGTTIN']=149
    ['SIGTTOU']=150
    ['SIGURG']=151
    ['SIGXCPU']=152
    ['SIGXFSZ']=153
    ['SIGVTALRM']=154
    ['SIGPROF']=155
    ['SIGWINCH']=156
    ['SIGIO']=157
    ['SIGPWR']=158
    ['SIGSYS']=159
    ['SIGRTMIN']=160
    ['SIGRTMIN+1']=161
    ['SIGRTMIN+2']=162
    ['SIGRTMIN+3']=163
    ['SIGRTMIN+4']=164
    ['SIGRTMIN+5']=165
    ['SIGRTMIN+6']=166
    ['SIGRTMIN+7']=167
    ['SIGRTMIN+8']=168
    ['SIGRTMIN+9']=169
    ['SIGRTMIN+10']=170
    ['SIGRTMIN+11']=171
    ['SIGRTMIN+12']=172
    ['SIGRTMIN+13']=173
    ['SIGRTMIN+14']=174
    ['SIGRTMIN+15']=175
    ['SIGRTMAX-14']=176
    ['SIGRTMAX-13']=177
    ['SIGRTMAX-12']=178
    ['SIGRTMAX-11']=179
    ['SIGRTMAX-10']=180
    ['SIGRTMAX-9']=181
    ['SIGRTMAX-8']=182
    ['SIGRTMAX-7']=183
    ['SIGRTMAX-6']=184
    ['SIGRTMAX-5']=185
    ['SIGRTMAX-4']=186
    ['SIGRTMAX-3']=187
    ['SIGRTMAX-2']=188
    ['SIGRTMAX-1']=189
    ['SIGRTMAX']=190
    ['BAD_VERS']=254
)