/* maze.c   a maze generator
   Jon Bennett
        jcrb@cs.cmu.edu
   */

/* the maze is generated by making a list of all the internal hedges
   and randomizing it, then going lineraly through the list, we take a
   hedge and se if the maze squares adjacent to it are already connected
   (with find) is not the we connect them (with link), this prevents us
   from creating a maze with a cycle because we will not link two maze
   squares that are already connect by some path */
#include <stdio.h>

#define DOWN 1
#define RIGHT 2

struct maze_loc{
    int rank;
    int x,y;
    struct maze_loc *ptr;
};
struct hedge_loc{
    int x,y,pos,on;
};

struct maze_loc *_maze;
struct hedge_loc *hedge;
struct hedge_loc **hedge_list;

void link__(struct maze_loc *a, struct maze_loc *b)
{
    if(a->rank == b->rank){
        a->ptr=b;
        b->rank++;
        return;
    }
    if(a->rank > b->rank){
        b->ptr=a;
        return;
    }
    a->ptr=b;
}

struct maze_loc *find(struct maze_loc *a)
{
    if(a != a->ptr){
        a->ptr = find(a->ptr);
    }
    return a->ptr;
}

NSMutableArray * maze_main()
{
    int x,y,i,j,k,l;
//	int tmp;
    struct maze_loc *a,*b;
    struct hedge_loc *htmp;


    srandom((unsigned int)time(0));
    x=kMaxX;
    y=kMaxY;

    /*malloc the maze and hedges */
    _maze=(struct maze_loc *)malloc(sizeof(struct maze_loc)*x*y);
    hedge=(struct hedge_loc *)malloc(sizeof(struct
hedge_loc)*((x*(y-1))+((x-1)*y)));
    hedge_list=(struct hedge_loc **)malloc(sizeof(struct hedge_loc
*)*((x*(y-1))+((x-1)*y)));

    /*init maze*/

    for(j=0;j<y;j++){
        for(i=0;i<x;i++){
            _maze[x*j+i].x = i;
            _maze[x*j+i].y = j;
            _maze[x*j+i].ptr = &_maze[x*j+i];
            _maze[x*j+i].rank=0;
        }
    }

    /*init hedges*/
    for(j=0;j<(y-1);j++){
        for(i=0;i<x;i++){
            hedge[x*j+i].x = i;
            hedge[x*j+i].y = j;
            hedge[x*j+i].pos=DOWN;
            hedge[x*j+i].on=1;
            hedge_list[x*j+i]= &hedge[x*j+i];
        }
    }
    k=x*(y-1);

    for(j=0;j<y;j++){
        for(i=0;i<(x-1);i++){
            hedge[k+(x-1)*j+i].x = i;
            hedge[k+(x-1)*j+i].y = j;
            hedge[k+(x-1)*j+i].pos=RIGHT;
            hedge[k+(x-1)*j+i].on=1;
            hedge_list[k+(x-1)*j+i]= &hedge[k+(x-1)*j+i];
        }
    }

    k=(x*(y-1))+((x-1)*y);

    /*randomize hedges*/
    for(i=(k-1);i>0;i--){
        htmp=hedge_list[i];
        j=random()%i;
        hedge_list[i]=hedge_list[j];
        hedge_list[j]=htmp;
    }
    fflush(stdout);

    l=k;

    /*create maze*/
    for(i=0;i<l;i++){
        j=hedge_list[i]->x;
        k=hedge_list[i]->y;
        a=find(&_maze[x*k+j]);
        if(hedge_list[i]->pos==DOWN){
            b=find(&_maze[x*(k+1)+j]);
        } else {
            b=find(&_maze[x*k+j+1]);
        }
        if(a!=b){
            link__(a,b);
            hedge_list[i]->on=0;
        }
    }
	NSMutableArray *li = [[NSMutableArray alloc] initWithCapacity:kMaxY*2+1];
	NSMutableString *str = [[NSMutableString alloc] init];
	
	[str appendString:@"#"];
    for(i=0;i<x;i++){
		[str appendString:@"##"];
    }
	[li addObject:[str copy]];
	[str setString:@""];


    l=x*(y-1);

    for(j=0;j<y;j++){
		[str appendString:@"#"];
        for(i=0;i<(x-1);i++){
            if(hedge[l+(x-1)*j+i].on){
				[str appendString:@" #"];
            } else {
				[str appendString:@"  "];
            }
        }
		[str appendString:@" #"];
		[li addObject:[str copy]];
		[str setString:@"#"];

        if(j<(y-1)){
            for(i=0;i<x;i++){
               if(hedge[j*x+i].on){
				   [str appendString:@"##"];
               } else {
				   [str appendString:@" #"];

               }
            }
			[li addObject:[str copy]];
			[str setString:@""];
        }

    }

    for(i=0;i<x;i++){
		[str appendString:@"##"];
    }
	[li addObject:[str copy]];
	[str setString:@""];
	
	return li;
}
